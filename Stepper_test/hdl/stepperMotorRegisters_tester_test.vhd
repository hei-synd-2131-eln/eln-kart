--
-- VHDL Architecture Stepper_test.stepperMotorRegisters_tester.test
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 09:04:47 16.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

Library Kart;
  USE Kart.Kart.all;

LIBRARY Common_test;
  USE Common_test.testutils.all;

LIBRARY std;
  USE std.textio.ALL;

library ieee;
  USE ieee.std_logic_textio.ALL;
  use ieee.math_real.all;

ARCHITECTURE test OF stepperMotorRegisters_tester IS

  constant clockPeriod  : time := 1.0/CLOCK_FREQUENCY * 1 sec;
  signal sClock         : std_uLogic := '1';
  signal sReset         : std_uLogic ;
  signal testInfo       : string(1 to 40) := (others => ' ');

BEGIN

  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 0.9*clockPeriod;

  process
  begin
    testInfo <= pad("stepperMotor Test Bench", testInfo'length);
    addressIn <= symbolSizeType(to_unsigned(0, addressIn'length));
    dataIn <= dataRegisterType(to_unsigned(0, dataIn'length));
    regWr <= '0';
    stepperSendAuth <= '0';
    actualAngle <= (others=>'0');
    reached <= '0';
    stepperEnd <= '0';

    wait for 5 us;
    write(output,
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "-- Starting testbench" & lf &
      "--" &
      lf & lf
    );
    wait until rising_edge(clock);


    -- Load the registers
    for indx in 0 to STP_REG_COUNT-1 loop
      testInfo <= pad("Loading register " & to_string(indx), testInfo'length);
      wait for clockPeriod;
      addressIn <= symbolSizeType'(
        std_ulogic_vector(to_unsigned(REG_STEP_ADDR, REG_ADDR_MSB_NB_BITS))
        & FRAME_WBIT_VALUE &
        std_ulogic_vector(to_unsigned(indx, REG_ADDR_MAXNBREG_BITS))
      );
      dataIn <= dataRegisterType(to_unsigned(indx+1, dataIn'length));
      regWr <= '1', '0' after clockPeriod;
      wait for 50*clockPeriod;
    end loop;

    assert clockDivider = to_unsigned(1,STP_dividerBitNb)
      report "clockDivider is not loaded correctly"
      severity failure;
    assert targetAngle = to_unsigned(2,STP_angleBitNb)
      report "targetAngle is not loaded correctly"
      severity failure;

    -- Send a data with wrong address asking for a send
    testInfo <= pad("Ask data but wrong address", testInfo'length);
    addressIn <= symbolSizeType'(
        std_ulogic_vector(to_unsigned(REG_STEP_ADDR+1, REG_ADDR_MSB_NB_BITS))
        & not FRAME_WBIT_VALUE &
        std_ulogic_vector(to_unsigned(0, REG_ADDR_MAXNBREG_BITS))
    );
    dataIn <= dataRegisterType(to_unsigned(0, dataIn'length));
    regWr <= '1', '0' after clockPeriod;
    wait for 2*clockPeriod;
    assert stepperSendRequest = '0'
      report "System should not answer to the wrong address"
      severity failure;
    wait for 50*clockPeriod;

    -- Ask to send a register
    testInfo <= pad("Ask for targetAngle", testInfo'length);
    addressIn <= symbolSizeType'(
        std_ulogic_vector(to_unsigned(REG_STEP_ADDR, REG_ADDR_MSB_NB_BITS))
        & not FRAME_WBIT_VALUE &
        std_ulogic_vector(to_unsigned(STP_TARGETANGLE_REG_POS, REG_ADDR_MAXNBREG_BITS))
    );
    dataIn <= (others=> '1');
    regWr <= '1', '0' after clockPeriod;
    wait for 2*clockPeriod;
    assert stepperSendRequest = '1' and 
      stepperDataToSend = dataRegisterType(to_unsigned(STP_TARGETANGLE_REG_POS+1, dataIn'length)) and
      stepperAddressToSend = addressIn
      report "System should answer to the address"
      severity failure;
    wait for 100*clockPeriod;
    stepperSendAuth <= '1', '0' after 1.05*clockPeriod;
    wait for 2*clockPeriod;
    assert stepperSendRequest = '0'
      report "System should stop sending"
      severity failure;
    wait for 50*clockPeriod;

    -- stepperEnd change should send the register
    testInfo <= pad("Sending stepperEnd", testInfo'length);
    stepperEnd <= '1';
    wait for 2*clockPeriod;
    assert stepperSendRequest = '1'
      report "System should send stepperEnd change"
      severity failure;
    stepperSendAuth <= '1', '0' after 1.05*clockPeriod;
    wait for 50*clockPeriod;

    -- reached change should send the register
    testInfo <= pad("Sending reached", testInfo'length);
    reached <= '1';
    wait for 2*clockPeriod;
    assert stepperSendRequest = '1'
      report "System should send reached change"
      severity failure;
    stepperSendAuth <= '1', '0' after 1.05*clockPeriod;
    wait for 50*clockPeriod;

    -- actualAngle change should not be enough to trigger sending
    testInfo <= pad("ActualAngle change not big enough", testInfo'length);
    actualAngle <= resize(STP_ANGLE_DELTA -
        to_unsigned(1,STP_angleBitNb), STP_angleBitNb);
    wait for 2*clockPeriod;
    assert stepperSendRequest = '0'
      report "actualAngle should not be sent yet"
      severity failure;
    wait for 50*clockPeriod;

    -- actualAngle change should not be enough to trigger sending
    testInfo <= pad("ActualAngle sending", testInfo'length);
    actualAngle <= resize(STP_ANGLE_DELTA +
        to_unsigned(1,STP_angleBitNb), STP_angleBitNb);
    wait for 3*clockPeriod;
    assert stepperSendRequest = '1'
      report "actualAngle should be sent yet"
      severity failure;
    stepperSendAuth <= '1', '0' after 1.05*clockPeriod;
    wait for 50*clockPeriod;

    -- End
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

END ARCHITECTURE test;
