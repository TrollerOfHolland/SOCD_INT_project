library ieee, std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tvc_siso_gen is
  generic (DATA_WIDTH: natural;
           STACK_SIZE: natural;
           half_clock_period: time := 100 ns;
           -- only used for file_io architecture
           in_file_name: string := "/dev/urandom";
           --in_file_name: string := "rpn.in";
           out_file_name: string := "rpn.out");
  -- note that the signals are the same as in the entity siso_gen 
  -- where inputs have become outputs and vice versa 
  port (data_in: out std_logic_vector(DATA_WIDTH-1 downto 0);
        clk: out std_logic;
        reset: out std_logic;

        req: in std_logic;
        data_out: in std_logic_vector(DATA_WIDTH-1 downto 0);
        ready: in std_logic);
end tvc_siso_gen;

architecture tvc_siso_gen_arch of tvc_siso_gen is
  -- input file
  file in_file: text open Read_mode is in_file_name;
  -- output file
  file out_file: text open Write_mode is out_file_name;

  function minimum(a, b: integer) return integer is
  begin
    if a < b then return a;
    else return b; end if;
  end function minimum;


  -- internal clock
  signal clk_i: std_logic;
begin
  clk <= clk_i;

  -- generate clock
  clock: process
  begin
    clk_i <= '1';
    wait for half_clock_period;
    clk_i <= '0';
    wait for half_clock_period;
  end process clock;

  stimuli: process (clk_i)
    variable first: boolean := true;

    variable inline, outline: line;
    variable good: boolean;

    variable input: character;
    variable output: integer;

    variable time_out_counter: integer;

    type int_array is array (0 to STACK_SIZE - 1) of integer; 
    variable stack: int_array;
    variable sp: natural := 0;
    variable first_digit: boolean := true;

  begin
    if falling_edge(clk_i)
    then
      -- handle reset; reset signal is high during first clock cycle only
      if first 
      then
        first := false;
        reset <= '1';
        time_out_counter := 0;
        for i in 0 to STACK_SIZE - 1 loop
          stack(i) := 0;
        end loop;
      else
        reset <= '0';

        -- handle output
        if ready = '1'
        then
          output := to_integer(unsigned(data_out));
          write(outline, input);
          writeline(out_file, outline);
          -- report "Checking: " & to_string(to_integer(unsigned(data_out))) & " | " & to_string(stack(0));
          if (to_integer(unsigned(data_out)) /= stack(0)) then
            report "Failure!!!" severity failure;
          end if;
        end if; -- ready

        -- handle input signal, take it from file
        if req = '1'
        then
          read(inline, input, good);

          -- Skip spaces
          while good and input = ' ' loop
              read(inline, input, good);
          end loop;

          if good
          then
              case input is
                  when '0' to '9' => if first_digit then
                          if (sp + 1 <= STACK_SIZE) then
                              sp := sp + 1;
                              for i in minimum(sp-1, STACK_SIZE - 2) downto 0 loop
                                  stack(i + 1) := stack(i);
                              end loop;
                              stack(0) := character'pos(input) - 48;  -- 48 is ascii offset of numbers
                          end if;
                          first_digit := false;
                      else
                          stack(0) := (stack(0) * 10 + character'pos(input) - 48) mod (2 ** DATA_WIDTH);
                      end if;
                  when '+' | '*' | '-' => if input = '+' then
                        stack(0) := (stack(0) + stack(1)) mod (2 ** DATA_WIDTH);
                      elsif input = '-' then
                          stack(0) := (stack(1) - stack(0)) mod (2 ** DATA_WIDTH);
                      else
                          stack(0) := (stack(0) * stack(1)) mod (2 ** DATA_WIDTH);
                      end if;
                      for i in 1 to minimum(sp - 1, STACK_SIZE - 2) loop
                          stack(i) := stack(i+1);
                      end loop;
                      stack(STACK_SIZE - 1) := 0;
                      if sp > 1
                      then
                          sp := sp - 1;
                      end if;
                      first_digit := true;
                  when 'E' => first_digit := true;
                  when others => null;

              end case;
              -- report "Test_Stack: " & to_string(stack(0)) & " | " & to_string(stack(1));
              -- encode input as a 2's complement signal
              data_in <= std_logic_vector(to_unsigned(character'pos(input), DATA_WIDTH));
              time_out_counter := 0;
          else
              reset <= '1';
              assert not endfile(in_file)
                report "OK! Simulation stopped at end of input file." 
                severity failure;
              readline(in_file, inline);

              sp := 0;
              for i in 0 to STACK_SIZE - 1 loop
                  stack(i) := 0;
              end loop;
              first_digit := true;
          end if;
        else
          time_out_counter := time_out_counter + 1;
          if (time_out_counter > 1000)
          then
            assert false
              report "Time out while waiting for req!" severity failure;
          end if;
        end if; -- req = '1'
      end if; -- first
    end if; -- falling_edge(clk)
  end process stimuli;
end tvc_siso_gen_arch;
