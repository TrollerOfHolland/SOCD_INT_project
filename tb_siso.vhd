library ieee;
use ieee.std_logic_1164.all;

entity tb_siso_gen is
    generic (DATA_WIDTH: natural := 8;
            STACK_SIZE: integer := 100;
            half_clock_period: time := 5 ns);
end entity tb_siso_gen;

architecture structure of tb_siso_gen is
    component siso_gen is
        generic (DATA_WIDTH: integer;
                 STACK_SIZE: integer);
          port (data_in: in std_logic_vector(DATA_WIDTH - 1 downto 0);
            clk: in std_logic;
            reset: in std_logic;

            req: out std_logic;
            data_out: out std_logic_vector(DATA_WIDTH - 1 downto 0);
            ready: out std_logic);
    end component siso_gen;

    component tvc_siso_gen is
      generic (DATA_WIDTH: natural;
               STACK_SIZE: natural;
               half_clock_period: time := 100 ns;
               -- only used for file_io architecture
               in_file_name: string;
               out_file_name: string);
      -- note that the signals are the same as in the entity siso_gen 
      -- where inputs have become outputs and vice versa 
      port (data_in: out std_logic_vector(DATA_WIDTH-1 downto 0);
            clk: out std_logic;
            reset: out std_logic;

            req: in std_logic;
            data_out: in std_logic_vector(DATA_WIDTH-1 downto 0);
            ready: in std_logic);
    end component tvc_siso_gen;
            
    signal data_in, data_out: std_logic_vector(DATA_WIDTH - 1 downto 0); 
    signal clk, reset, req, ready: std_logic;
begin
    duv: siso_gen
     generic map(DATA_WIDTH => DATA_WIDTH,
                 STACK_SIZE => STACK_SIZE)
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
        DATA_WIDTH => DATA_WIDTH,
        STACK_SIZE => STACK_SIZE,
        half_clock_period => half_clock_period,
        in_file_name => "/dev/urandom",
        out_file_name => "rpn.out"
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

entity tb_siso_gen_top is
end tb_siso_gen_top;

architecture top of tb_siso_gen_top is
  component tb_siso_gen
    generic(DATA_WIDTH: natural := 8);
  end component;
begin
  tg: tb_siso_gen;
end top;