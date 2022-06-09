LIBRARY std;
  USE std.textio.ALL;

LIBRARY ieee;
  USE ieee.std_logic_textio.ALL;

LIBRARY Common_test;
  USE Common_test.testutils.all;

Library Kart;
  Use Kart.Kart.all;

ARCHITECTURE test OF stepperMotorController_tester IS

  constant clockPeriod  : time := 1.0/CLOCK_FREQUENCY * 1 sec;
  signal sClock         : std_uLogic := '1';
  signal sReset         : std_uLogic ;

  constant testInterval : time := 200 us;
  signal testInfo       : string(1 to 40) := (others => ' ');


  -- DUT readout values
  signal dutReached: std_ulogic;
  signal dutPosition: natural;

  -- Coils analysis
  signal coils, prevCoils: std_ulogic_vector(1 to 5);
  signal turn1to4, turnBack: std_ulogic;
  signal lastEvent: time;
  signal onTime: integer;

  -- Steering values
    -- f of 100kHz / divideValue, here 10kHz
  constant stepDivideValue: positive := 10;
  constant angleMaxValue: positive := 1E3;
  signal hardwareOrientation: natural;

  -- Registers definitions
  constant stpBaseReadAddr : natural := REG_STEP_ADDR * 2**6;
  constant stpBaseWriteAddr : natural := stpBaseReadAddr + 1 * 2**5;

  constant prescalerWRAddr : natural :=
    stpBaseWriteAddr + STP_CLOCKDIVIDER_REG_POS;
  constant targetAngleWRAddr : natural :=
    stpBaseWriteAddr + STP_TARGETANGLE_REG_POS;

  constant actualAngleRDAddr : natural := stpBaseReadAddr + STP_ANGLE_EXT_REG_POS;
  constant hwRDAddr : natural := stpBaseReadAddr + STP_HW_EXT_REG_POS;

  constant stpPeriod : time := 1 sec / (STP_MAX_FREQ / real(stepDivideValue));

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 0.9*clockPeriod;

  ------------------------------------------------------------------------------
                                                                       -- others
  hwOrientation <= dataRegisterType
  (
    to_unsigned(hardwareOrientation, hwOrientation'length)
  );

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process

      procedure setReg(constant address : in natural;
                       constant data    : in natural) is
      begin
        assert(
          to_unsigned(address, addressIn'length)(REG_ADDR_GET_BIT_POSITION)
          = '1') report "Address is not writable" severity failure;
        addressIn <= symbolSizeType(to_unsigned(address, addressIn'length));
        dataIn <= dataRegisterType(to_unsigned(data, dataIn'length));
        regWr <= '1', '0' after clockPeriod * 1.1;
      end procedure;


      procedure readReg(constant address : in natural) is
      begin
        assert(
          to_unsigned(address, addressIn'length)(REG_ADDR_GET_BIT_POSITION)
          = '0') report "Address is not readable" severity failure;
        addressIn <= symbolSizeType(to_unsigned(address, addressIn'length));
        dataIn <= dataRegisterType(to_unsigned(0, dataIn'length));
        regWr <= '1', '0' after clockPeriod * 1.1;
      end procedure;

  begin
    -- Init signals
    testMode <= '0';
    stepperEnd <= '0';
    hardwareOrientation <= 2#111#;
    dataIn <= (others=>'0');
    addressIn <= (others=>'0');
    regWr <= '0';
    stepperSendAuth <= '1';
    dutReached <= '1';
    dutPosition <= 0;

    wait for 1 ns;
    write(output,
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "-- Starting testbench" & lf &
      "--" &
      lf & lf
    );

                                                               -- send prescaler
    testInfo <= pad("Init", testInfo'length);
    wait for testInterval;
    write(output,
      "Sending step divider value " & sprintf("%d", stepDivideValue) &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(prescalerWRAddr, stepDivideValue);
    wait for testInterval;

                                                           -- send quarter angle
    testInfo <= pad("Turn 1/4", testInfo'length);
    write(output,
    "Sending turn control to quarter angle" &
    " at time " & integer'image(now/1 us) & " us" &
    lf & lf
    );
    setReg(targetAngleWRAddr, angleMaxValue/4);
    wait for testInterval;

                                                                 -- send restart
    testInfo <= pad("Restart", testInfo'length);
    write(output,
      "Restarting to zero position" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    hardwareOrientation <= 16#10# + hardwareOrientation;
    wait for testInterval/10;
    hardwareOrientation <= hardwareOrientation - 16#10#;
    wait for 5*testInterval;
    assert turn1to4 = turnBack
      report "Coil direction error"
      severity error;
    assert turn1to4 /= turnBack
      report "Coil direction OK"
      severity note;

                                                           -- actuate end switch
    testInfo <= pad("End switch local", testInfo'length);
    write(output,
      "Activating end of turn switch" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    stepperEnd <= '1', '0' after testInterval/10;
                                                     -- wait until angle reached
    wait for (3+angleMaxValue/4) * stpPeriod;
    wait for testInterval;

                                                              -- send half angle
    testInfo <= pad("Turn 1/2", testInfo'length);
    write(output,
      "Sending turn control to half angle" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(targetAngleWRAddr, angleMaxValue/2);
    wait for testInterval;

                                                               -- ask for status 
                    -- wait for less than quarter angle delay and ask for status
    wait for angleMaxValue/4 * stpPeriod / 2;
    testInfo <= pad("Ask for status", testInfo'length);
    write(output,
      "Asking for status" &
      " at time " & integer'image(now/1 us) & " us" &
      lf &
      "  Reached => 0 | STPEnd => 0 " &
      lf & lf
    );
    readReg(hwRDAddr);
    stepperSendAuth <= '0';
    wait until stepperSendRequest = '1';
    dutReached <= stepperDataToSend(1);
    stepperSendAuth <= '1', '0' after 1.1 * clockPeriod, '1' after 2 * clockPeriod;
    assert dutReached /= '0'
      report "Reached flag error"
      severity error;
    assert dutReached = '0'
      report "Reached flag OK"
      severity note;
    assert turn1to4 = not turnBack
      report "Coil direction error"
      severity error;
    assert turn1to4 = turnBack
      report"Coil direction OK"
      severity note;

                                      -- wait for end of turn and ask for status
    testInfo <= pad("Ending turn", testInfo'length);
    wait for angleMaxValue/6 * stpPeriod;
    testInfo <= pad("Ask for status", testInfo'length);
    write(output,
      "Asking for status" &
      " at time " & integer'image(now/1 us) & " us" &
      lf &
      "    Reached => 1 | STPEnd => 1 " &
      lf & lf
    );
    readReg(hwRDAddr);
    stepperSendAuth <= '0';
    wait until stepperSendRequest = '1';
    dutReached <= stepperDataToSend(1);
    stepperSendAuth <= '1', '0' after 1.1 * clockPeriod, '1' after 2 * clockPeriod;
    assert dutReached /= '1'
      report "Reached flag error"
      severity error;
    assert dutReached = '1'
      report "Reached flag OK"
      severity note;
    wait for testInterval;

                                                             -- ask for position
    testInfo <= pad("Ask for position", testInfo'length);
    write(output,
      "Asking for position" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    readReg(actualAngleRDAddr);
    stepperSendAuth <= '0';
    wait until stepperSendRequest = '1';
    dutPosition <= natural(to_integer(unsigned(stepperDataToSend)));
    stepperSendAuth <= '1', '0' after 1.1 * clockPeriod, '1' after 2 * clockPeriod;
    assert dutPosition /= angleMaxValue/2
      report "Position readback error"
      severity error;
    assert dutPosition = angleMaxValue/2
      report "Position readback OK"
      severity note;
    wait for testInterval;

                                                              -- send full angle
    testInfo <= pad("Turn full", testInfo'length);
    write(output,
      "Sending turn control to full angle" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(targetAngleWRAddr, angleMaxValue);
    wait for 2*angleMaxValue/3 * stpPeriod;
    wait for testInterval/2;

                                                              -- send zero angle
    testInfo <= pad("Turn back", testInfo'length);
    write(output,
      "Sending turn control to angle zero" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(targetAngleWRAddr, 0);
    wait for 5*angleMaxValue/4 * stpPeriod;
    assert turn1to4 = turnBack
      report "Coil direction error"
      severity error;
    assert turn1to4 /= turnBack
      report "Coil direction OK"
      severity note;
    wait for testInterval;

                                               -- assert end contact HWControl
    testInfo <= pad("End switch mst", testInfo'length);
    write(output,
      "Emulating end contact ON" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    hardwareOrientation <= 16#08# + hardwareOrientation;
    wait for testInterval;
                                             -- deassert end contact from master
    write(output,
      "Sending end contact OFF" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    hardwareOrientation <= hardwareOrientation - 16#08#;
    wait for testInterval;

                                                              -- send half angle
    testInfo <= pad("Turn 1/2", testInfo'length);
    write(output,
      "Sending turn control to half angle" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(targetAngleWRAddr, angleMaxValue/2);
    wait for angleMaxValue/2 * stpPeriod;
    assert turn1to4 = not turnBack
      report "Coil direction error"
      severity error;
    assert turn1to4 = turnBack
      report "Coil direction OK"
      severity note;

                                                  -- change hardware orientation
    testInfo <= pad("Restart on", testInfo'length);
    write(output,
      "Restarting with different hardware orientation controls" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    hardwareOrientation <= 2#011# + 16#10#;
    wait for testInterval;
    assert turn1to4 /= turnBack
      report "Coil direction error"
      severity error;
    assert turn1to4 = turnBack
      report "Coil direction OK"
      severity note;
    wait for testInterval;

                                                         -- deassert restart bit
    testInfo <= pad("Restart off", testInfo'length);
    write(output,
      "Ending restart control" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    hardwareOrientation <= 2#011#;
    wait for testInterval;

                                                              -- send zero angle
    testInfo <= pad("Turn back", testInfo'length);
    write(output,
      "Sending turn control to angle zero" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    setReg(targetAngleWRAddr, 0);
    wait for angleMaxValue/3 * stpPeriod;
    stepperEnd <= '1', '0' after testInterval/10;
    wait for 10*testInterval;

                                                            -- end of simulation
    testInfo <= pad("End of simulation", testInfo'length);
    wait for 10*testInterval;
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

  ------------------------------------------------------------------------------
                                                                -- coil analysis
  coils <= (coil1, coil2, coil3, coil4, coil1);

  findDir: process(coils)
    variable onTime_var: integer;
  begin
    turn1to4 <= '0';
    for index in 2 to coils'right loop
      if coils(index) = '1' then
        if prevCoils(index-1) = '1' then
          turn1to4 <= '1';
        end if;
      end if;
    end loop;
    prevCoils <= coils after 1 ns;
    if unsigned(prevCoils) /= 0 then
      onTime_var := integer( (now - lastEvent) / clockPeriod);
      onTime <= onTime_var;
      if unsigned(coils) /= 0 then
        assert onTime_var <= stpPeriod / clockPeriod
          report "Coil on for too long"
          severity error;
      end if;
    end if;
    lastEvent <= now;
  end process findDir;

  turnBack <= '1' when (hardwareOrientation/2 = 1) or (hardwareOrientation/2 = 2)
    else '0';

END ARCHITECTURE test;
