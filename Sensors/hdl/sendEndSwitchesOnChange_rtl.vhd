--
-- VHDL Architecture Sensors.sendEndSwitchesOnChange.rtl
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 13:11:58 17.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

Library Kart;
  USE Kart.Kart.ALL;

ARCHITECTURE rtl OF sendEndSwitchesOnChange IS
BEGIN

  -- Send when any edge is detected
  sendEndSwitches <= '1' when 
    unsigned(ends_edges) > (1 to SENS_endSwitchNb => '0') else '0';

END ARCHITECTURE rtl;
