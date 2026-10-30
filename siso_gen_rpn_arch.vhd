-- Author: Tristan Bottenberg

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rpn of siso_gen is
    signal decoder_out: std_logic_vector(3 downto 0);
    signal ALU_left, ALU_right, ALU_out, data_a, data_b, data_i: unsigned(DATA_WIDTH - 1 downto 0);
    signal is_operator, valid, enabled, ful: std_logic;
    signal pshpop, operator: std_logic_vector(1 downto 0);
    signal first_digit: boolean := true;
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
    operator <= decoder_out(1 downto 0);
    ALU_right <= data_a;
    ALU_left <= data_b;

    seq: process(clk, reset)

    begin
        if rising_edge(clk)
        then
            if (reset = '1')
            then
                ready <= '0';
                first_digit <= true;
            elsif (valid = '1')
            then
                ready <= '1';
                first_digit <= (is_operator = '1');
            else
                ready <= '0';
                first_digit <= first_digit;
            end if;
        end if;
    end process seq;

    process(is_operator, valid, decoder_out, ALU_out, data_a, first_digit)
    begin
        if (valid = '1')
        then
            if (is_operator = '1')
            then
                if (decoder_out(1 downto 0) = "11")
                then
                    pshpop <= "00";
                    data_i <= (others => '0');
                else
                    pshpop <= "10";
                    data_i <= ALU_out; 
                end if;
            else
                if first_digit
                then
                    pshpop <= "01";
                    data_i <= unsigned((DATA_WIDTH - 1 downto 4 => '0') & decoder_out);
                else
                    pshpop <= "11";
                    data_i <= shift_left(data_a, 1) + shift_left(data_a, 3) + unsigned((DATA_WIDTH - 1 downto 4 => '0') & decoder_out);
                end if;
            end if;
        else
            pshpop <= "00";
            data_i <= (others => '0');
        end if;
    end process; 

   data_out <= std_logic_vector(data_a);
   req <= '1';

end rpn;
