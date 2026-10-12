library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rpn of siso8 is
    signal decoder_out: std_logic_vector(3 downto 0);
    signal ALU_left, ALU_right, ALU_out, data_a, data_b, data_i: unsigned(DATA_WIDTH - 1 downto 0);
    signal is_operator, operator, valid, enabled, ful: std_logic;
    signal pshpop: std_logic_vector(1 downto 0);
begin

   input_decoder_inst: entity work.input_decoder
    generic map(
       DATA_WIDTH => DATA_WIDTH
   )
    port map(
       data_in => data_in,
       decoder_out => decoder_out,
       is_operator => is_operator,
       valid => valid
   ); 

    alu_inst: entity work.alu
     generic map(
        DATA_WIDTH => DATA_WIDTH
    )
     port map(
        ALU_left => ALU_left,
        ALU_right => ALU_right,
        ALU_out => ALU_out,
        enabled => enabled,
        operator => operator
    ); 

    shift_register_stack_inst: entity work.shift_register_stack
     generic map(
        STACK_SIZE => STACK_SIZE,
        DATA_WIDTH => DATA_WIDTH
    )
     port map(
        clk => clk,
        rst => reset,
        pshpop => pshpop,
        data_i => data_i,
        data_a => data_a,
        data_b => data_b,
        ful => ful
    );

    enabled <= valid and is_operator;
    operator <= decoder_out(0);
    ALU_left <= data_a;
    ALU_right <= data_b;
    process(is_operator, valid, decoder_out, ALU_out, data_a)
        variable first_digit: std_logic := '1';
    begin
        if (valid = '1')
        then
            if (is_operator = '1')
            then
                first_digit := '1';
                if (decoder_out(1) = '1')
                then
                    pshpop <= "00";
                    data_i <= (others => '0');
                else
                    pshpop <= "10";
                    data_i <= ALU_out; 
                end if;
            else
                if (first_digit = '1')
                then
                    pshpop <= "01";
                    data_i <= unsigned((DATA_WIDTH - 1 downto 4 => '0') & decoder_out);
                    first_digit := '0';
                else
                    pshpop <= "11";
                    data_i <= shift_left(data_a, 1) + shift_left(data_a, 3) + unsigned((DATA_WIDTH - 1 downto 4 => '0') & decoder_out);
                    first_digit := '0';
                end if;
            end if;
        else
            pshpop <= "00";
            data_i <= (others => '0');
        end if;
    end process; 

   data_out <= std_logic_vector(data_a);
   req <= '1';
   ready <= not reset;

end rpn;
