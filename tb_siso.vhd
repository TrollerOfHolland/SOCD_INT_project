library ieee;
use ieee.std_logic_1164.all;

entity tb_siso8 is
    generic(WORD_LENGTH: integer := 8;
            half_clock_period: time := 5 ns);
end entity tb_siso8;

architecture structure of tb_siso8 is
    component siso8 is
        generic (WORD_LENGTH: integer);
          port (data_in: in std_logic_vector(WORD_LENGTH - 1 downto 0);
            clk: in std_logic;
            reset: in std_logic;

            req: out std_logic;
            data_out: out std_logic_vector(WORD_LENGTH - 1 downto 0);
            ready: out std_logic);
    end component siso8;

    component tvc_siso_gen is
      generic (word_length: natural;
               half_clock_period: time := 100 ns;
               -- only used for file_io architecture
               in_file_name: string := "rpn.in";
               out_file_name: string := "rpn.out");
      -- note that the signals are the same as in the entity siso_gen 
      -- where inputs have become outputs and vice versa 
      port (data_in: out std_logic_vector(word_length-1 downto 0);
            clk: out std_logic;
            reset: out std_logic;

            req: in std_logic;
            data_out: in std_logic_vector(word_length-1 downto 0);
            ready: in std_logic);
    end component tvc_siso_gen;
            
    signal data_in, data_out: std_logic_vector(WORD_LENGTH - 1 downto 0); 
    signal clk, reset, req, ready, operator, valid: std_logic;
begin
    duv: siso8
     generic map(WORD_LENGTH => WORD_LENGTH)
     port map(
        data_in => data_in,
        clk => clk,
        reset => reset,
        req => req,
        data_out => data_out,
        ready => ready
    );

    tvc: tvc_siso_gen
     generic map(
        word_length => word_length,
        half_clock_period => half_clock_period,
        in_file_name => "rpn.in"
    )
     port map(
        data_in => data_in,
        clk => clk,
        reset => reset,
        req => req,
        data_out => data_out,
        ready => ready
    );

end structure;
