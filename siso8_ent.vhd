library ieee;
use ieee.std_logic_1164.all;

entity siso8 is
  port (data_in: in std_logic_vector(7 downto 0);
        clk: in std_logic;
        reset: in std_logic;

        req: out std_logic;
        data_out: out std_logic_vector(7 downto 0);
        ready: out std_logic);
end siso8;
