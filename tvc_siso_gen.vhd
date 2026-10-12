library ieee, std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tvc_siso_gen is
  generic (DATA_WIDTH: natural;
           half_clock_period: time := 100 ns;
           -- only used for file_io architecture
           in_file_name: string := "rpn.in";
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
begin

  -- generate clock
  clock: process
  begin
    clk <= '1';
    wait for half_clock_period;
    clk <= '0';
    wait for half_clock_period;
  end process clock;

  stimuli: process (clk)
    variable first: boolean := true;

    variable inline, outline: line;
    variable good: boolean;

    variable input: character;
    variable output: integer;

    variable time_out_counter: integer;

  begin
    if falling_edge(clk)
    then
      -- handle reset; reset signal is high during first clock cycle only
      if first 
      then
        first := false;
        reset <= '1';
        time_out_counter := 0;
      else
        reset <= '0';

        -- handle output
        if ready = '1'
        then
          output := to_integer(unsigned(data_out));
          write(outline, output);
          writeline(out_file, outline);
        end if; -- ready

        -- handle input signal, take it from file
        if req = '1'
        then
          read(inline, input, good);
          if good
          then
              -- encode input as a 2's complement signal
              data_in <= std_logic_vector(to_unsigned(character'pos(input), 8));
              time_out_counter := 0;
          else
              reset <= '1';
              assert not endfile(in_file)
                report "OK! Simulation stopped at end of input file." 
                severity failure;
              readline(in_file, inline);
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
