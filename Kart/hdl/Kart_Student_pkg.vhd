--
-- VHDL Package Header Kart.Kart_Student
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 13:05:39 23.06.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE Kart_Student IS

--------------------------------------------------------------------------------
-- CHANGE THEM AS NEEDED, YOU CAN
--------------------------------------------------------------------------------
  -- When the circuit is in test mode
    --  (Stepper -> stepperMotorController -> testMode = '1'), the counter has
    --  to count quicker (to simplify on simulating the circuit).
    -- The following defines how many bits the counter should use.
    -- It simply creates a counter with that number of bits generating a pulse
    -- when it overflows, i.e. a pulse each 2**n / 10MHz => n = 8 : 25.6 [us]
  constant TESTMODE_PRESCALER_BIT_NB : positive := 8;

  -- Sensors
    -- The number of leds (or any output requiring a symmetrical PWM)
  constant NUMBER_OF_LEDS : positive := 4;

    -- The number of hall sensors
  constant NUMBER_OF_HALL_SENSORS : positive := 1;

    -- The number of external end switches (or any 0 - 3.3V input signal)
    -- A signal is sent to the smartphone on either rising or falling edge
  constant NUMBER_OF_EXT_END_SWITCHES : positive := 1;

    -- The number of proximity sensors used
    -- NORMALLY NONE
  constant NUMBER_OF_PROXIMITY_SENSORS : natural := 0;

    -- If the hallCounters block generates 2 pulses per turn (on rising AND 
    --  falling edges of the hallPulses) or only one
  constant HALLSENS_2PULSES_PER_TURN : std_ulogic := '1';

END Kart_Student;
