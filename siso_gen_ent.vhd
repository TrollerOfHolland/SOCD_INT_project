library ieee;
use ieee.std_logic_1164.all;

entity siso_gen is
  generic(DATA_WIDTH: integer := 8;
          STACK_SIZE: integer := 100);
  port (data_in: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        clk: in std_logic;
        reset: in std_logic;

        req: out std_logic;
        data_out: out std_logic_vector(DATA_WIDTH - 1 downto 0);
        ready: out std_logic);
end siso_gen;
