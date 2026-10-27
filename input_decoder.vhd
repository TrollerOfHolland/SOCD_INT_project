-- Author: Tristan Bottenberg

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_decoder is
  generic(DATA_WIDTH: integer);
  port (data_in: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        decoder_out: out std_logic_vector(3 downto 0);
        is_operator: out std_logic;
        valid: out std_logic);
end input_decoder;

architecture input_decoder_arch of input_decoder is

begin
    process(data_in)
    begin
        case to_integer(unsigned(data_in)) is
            when 48 to 57 =>
                decoder_out <= data_in(3 downto 0);
                is_operator <= '0';
                valid <= '1';
            when 69 => -- E
                decoder_out <= "0010";
                is_operator <= '1';
                valid <= '1';
            when 42 to 43 => -- */+
                decoder_out <= "000" & data_in(0);
                is_operator <= '1';
                valid <= '1';
            when others =>
                decoder_out <= (others => '0');
                is_operator <= '0';
                valid <= '0';
        end case;
    end process;

end input_decoder_arch;
