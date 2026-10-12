library ieee;
use ieee.std_logic_1164.all;

architecture rpn of siso8 is
    signal out_tmp: std_logic_vector(3 downto 0);
    signal operator, valid: std_logic;
begin

   input_decoder_inst: entity work.input_decoder
    generic map(
       WORD_LENGTH => WORD_LENGTH
   )
    port map(
       data_in => data_in,
       data_out => out_tmp,
       operator => operator,
       valid => valid
   ); 

   data_out <= "0000" & out_tmp;
   req <= '1';
   ready <= '0' when reset = '1' else '1';

end rpn;
