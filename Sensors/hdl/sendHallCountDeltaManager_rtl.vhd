--
-- VHDL Architecture Sensors.sendDeltaManager.rtl
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 13:24:40 17.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

Library Kart;
  USE Kart.Kart.ALL;

ARCHITECTURE rtl OF sendDeltaManager IS

  signal p_last_count : unsigned(dataSize-1 downto 0);
  signal p_di : signed(dataSize downto 0);
  signal p_lc : signed(dataSize downto 0);

BEGIN

  deltaSender:process(reset, clock)
  begin
    if reset = '1' then
      p_last_count <= (others=>'0');
      send <= '0';
    elsif rising_edge(clock) then
      if signed('0' & dataIn) > signed('0' & p_last_count) + to_signed(requiredDelta, p_last_count'length+1)
       or signed('0' & dataIn) < signed('0' & p_last_count) - to_signed(requiredDelta, p_last_count'length+1) then
        p_last_count <= dataIn;
        send <= '1';
      else
        send <= '0';
      end if;
    end if;
  end process deltaSender;

END ARCHITECTURE rtl;
