
architecture calc of siso8 is
begin
  -- the next process is sequential and only sensitive to clk and reset
  seq: process(clk, reset)
  begin
    if (reset = '1')
    then
      data_out <= (others => '0');
      ready <= '0';
    elsif rising_edge(clk)
    then
      data_out <= data_in;
      ready <= '1';
    end if;
  end process seq; 

  -- the system is intended to receive new data at each clock cycle 
  -- (after reset)
  req <= '1';
end calc;
