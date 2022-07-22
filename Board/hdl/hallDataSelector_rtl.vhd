Library Kart;
  Use Kart.Kart.all;

ARCHITECTURE rtl OF hallDataSelector IS
BEGIN

  hall_latch : for ind in 1 to STD_HALL_NUMBERS generate
    process(rst, clk)
    begin
      if rst = '1' then
        hallsOut(SENS_hallSensorNb + 1 - ind) <= '0';
      elsif rising_edge(clk) then
        hallsOut(SENS_hallSensorNb + 1 - ind) <= hallsIn(ind);
      end if;
    end process;
  end generate hall_latch;

  hall_inhibit : for ind in STD_HALL_NUMBERS+1 to SENS_hallSensorNb generate
    hallsOut(SENS_hallSensorNb + 1 - ind) <= '0';
  end generate hall_inhibit;

END ARCHITECTURE rtl;
