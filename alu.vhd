library ieee, std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (DATA_WIDTH: integer := 8);
    port (ALU_left: in unsigned(DATA_WIDTH - 1 downto 0);
          ALU_right: in unsigned(DATA_WIDTH - 1 downto 0);
          ALU_out: out unsigned(DATA_WIDTH - 1 downto 0);
          enabled: in std_logic;
          operator: in std_logic);
end alu;

architecture alu_arch of alu is
begin

    process(ALU_right, ALU_right, enabled, operator)
        variable mult_temp: unsigned(2*DATA_WIDTH - 1 downto 0);
    begin
        if (enabled = '0')
        then
            ALU_out <= (others => '0');
        elsif (operator = '0') -- multiplication
        then
            mult_temp := ALU_left * ALU_right;
            ALU_out <= mult_temp(DATA_WIDTH - 1 downto 0);
        else -- Addition
            ALU_out <= ALU_left + ALU_right;
        end if;
    end process;

end alu_arch;
