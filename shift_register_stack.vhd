-- Author: Lars Gortemaker

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

entity shift_register_stack is 
  generic (
    STACK_SIZE : integer := 100;
    DATA_WIDTH : integer := 32
);
port( clk   :   in std_logic;
      rst   :   in std_logic;
      pshpop:   in std_logic_vector(1 downto 0);  
      data_i:   in unsigned((DATA_WIDTH-1) downto 0);
      data_a:   out unsigned((DATA_WIDTH-1)  downto 0);
      data_b:   out unsigned((DATA_WIDTH-1)  downto 0);
      ful   :   out std_logic
); end shift_register_stack;

architecture arch of shift_register_stack is 
    type stack_array is array (0 to STACK_SIZE-1) of
        unsigned((DATA_WIDTH-1) downto 0);

    -- todo: size this based on stack size.
    signal stack : stack_array := (others => (others => '0'));
    signal count : unsigned(integer(ceil(log2(real(STACK_SIZE+1))))-1 downto 0) := (others => '0');
    signal ful_i : std_logic := '0'; 
begin 

  data_a <= stack(0);
  data_b <= stack(1);
  ful_i <= '1' when count >= STACK_SIZE else '0';
  ful <= ful_i;

  seq: process(clk, rst, data_i) begin
    if(rst = '1') then 
      stack <= (others => (others => '0'));
      count <= (others => '0');
    elsif rising_edge(clk) then 
      case pshpop is 
      when "01" => 
          if (ful_i = '0') then
            count <= count + 1;
            stack(0) <= data_i;
            for i in STACK_SIZE-1 downto 1 loop
              stack(i) <= stack(i-1);
            end loop;
          end if;
        when "10" =>
          if(count > 1) then
            count <= count - 1;
          elsif(count = 0) then
            count <= (0 => '1', others => '0');
          end if;
          stack(0) <= data_i;
          stack(STACK_SIZE-1) <= (others => '0');
          for i in 1 to STACK_SIZE-2 loop
            stack(i) <= stack(i+1);
          end loop;
        when "11" =>
          if(count = 0) then
            count <= (0 => '1', others => '0');
          end if;
          stack(0) <= data_i;
        when others =>
          null;
      end case;
    end if;
  end process;
end arch;
