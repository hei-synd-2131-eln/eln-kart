LIBRARY std;
  USE std.textio.ALL;

LIBRARY ieee;
  USE ieee.std_logic_textio.ALL;

LIBRARY Common_test;
  USE Common_test.testutils.all;

Library Kart;
  Use Kart.Kart.all;

ARCHITECTURE test OF sensors_tester IS

  constant clockPeriod  : time := 1.0/CLOCK_FREQUENCY * 1 sec;
  signal sClock         : std_uLogic := '1';
  signal sReset         : std_uLogic ;

  constant testInterval : time := 412 us;
  signal testInfo       : string(1 to 40) := (others => ' ');

  -- Hall pulses
  constant hallFrequency: real := 10.0E3;
  constant hallPeriod : time := 1.0/real(hallFrequency) * 1 sec;
  signal hallPulses_int: std_ulogic_vector(1 to SENS_hallSensorNb) :=
    (others => '0');
  type hallCountersType is array (1 to SENS_hallSensorNb) of integer;
  signal tbHallCounters: hallCountersType := (others => 0);

  -- Ultrasound ranger
    -- How many pulses should be counted
  signal tbRangerDistance: natural := 457;

  -- Registers definitions
  constant baseReadAddr : natural := REG_SENS_ADDR * 2**6;

  constant hallBaseRDAddr : natural :=
    baseReadAddr + SENS_HALLCNT_EXT_REG_POS;
  constant rangerRDAddr : natural :=
    baseReadAddr + SENS_RANGEFNDR_EXT_REG_POS;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 0.9*clockPeriod;

  process

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
    dataIn <= (others=>'0');
    addressIn <= (others=>'0');
    regWr <= '0';
    sensorsSendAuth <= '1';

    write(output,
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "-- Starting testbench" & lf &
      "--" &
      lf & lf
    );
    wait for testInterval;    

                                                           -- read Hall counters
    testInfo <= pad("Hall count 1", testInfo'length);
    write(output,
      "Reading Hall sensor counters" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    readReg(hallBaseRDAddr);
    wait until sensorsSendRequest = '1';
    assert to_integer(unsigned(sensorsDataToSend(SENS_hallCountBitNb-1 downto SENS_HALL_CNT_BITNB)))
      = tbHallCounters(1)
      report "Hall count 1 error"
      severity error;
    assert to_integer(unsigned(sensorsDataToSend(SENS_hallCountBitNb-1 downto SENS_HALL_CNT_BITNB)))
      /= tbHallCounters(1)
      report "Hall count 1 OK"
      severity note;
    wait for testInterval;

    testInfo <= pad("Hall count 2", testInfo'length);
    write(output,
      "Reading Hall sensor counters" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    readReg(hallBaseRDAddr+1);
    wait until sensorsSendRequest = '1';
    assert to_integer(unsigned(sensorsDataToSend(SENS_hallCountBitNb-1 downto SENS_HALL_CNT_BITNB)))
      = tbHallCounters(2)
      report "Hall count 2 error"
      severity error;
    assert to_integer(unsigned(sensorsDataToSend(SENS_hallCountBitNb-1 downto SENS_HALL_CNT_BITNB)))
      /= tbHallCounters(2)
      report "Hall count 2 OK"
      severity note;
    wait for testInterval;

                                                     -- read ultrasound distance
    testInfo <= pad("Ultrasound range", testInfo'length);
    write(output,
      "Reading ultrasound ranger distance" &
      " at time " & integer'image(now/1 us) & " us" &
      lf & lf
    );
    wait until distanceStart = '1';
    wait until distancePulse = '0';
    wait for 60 us;
    readReg(rangerRDAddr);
    wait until sensorsSendRequest = '1';
    assert abs(tbRangerDistance - to_integer(unsigned(sensorsDataToSend))) <= 2
      report "Ultrasound ranger count error"
      severity error;
    assert abs(tbRangerDistance - to_integer(unsigned(sensorsDataToSend))) > 2
      report "Ultrasound ranger OK"
      severity note;
    wait for testInterval;

                                                            -- end of simulation
    testInfo <= pad("End", testInfo'length);
    wait for testInterval;
    assert false
      report "End of simulation"
      severity failure;
    wait;

  end process;

  --============================================================================
                                                                 -- hall sensors
  buildPulses: for index in hallPulses_int'range generate
    hallPulses_int(index) <=
      not hallPulses_int(index) after hallPeriod * (index+1) / 2;
  end generate buildPulses;

  hallPulses <= hallPulses_int;

                                                                -- data decoding
  assignHallCounters: for index in tbHallCounters'range generate

    hall_2p_p_turn : if HALLSENS_2PULSES_PER_TURN = '1' generate
      cntPulses : process(hallPulses(index))
      begin
        if rising_edge(hallPulses(index)) or falling_edge(hallPulses(index)) then
          if tbHallCounters(index) + 1 >= SENS_HALLCOUNT_HALF_TURN_DELTA then
            tbHallCounters(index) <= 0;
          else
            tbHallCounters(index) <= tbHallCounters(index) + 1;
          end if;
        end if;
      end process cntPulses;
    end generate hall_2p_p_turn;

    hall_1p_p_turn : if HALLSENS_2PULSES_PER_TURN = '0' generate
      cntPulses : process(hallPulses(index))
      begin
        if rising_edge(hallPulses(index)) then
          if tbHallCounters(index) + 2 >= SENS_HALLCOUNT_HALF_TURN_DELTA then
            tbHallCounters(index) <= 0;
          else
            tbHallCounters(index) <= tbHallCounters(index) + 2;
          end if;
        end if;
      end process cntPulses;
    end generate hall_1p_p_turn;

  end generate assignHallCounters;

  ------------------------------------------------------------------------------
                                                            -- ultrasound ranger
  sendDistancePulse: process
  begin
    distancePulse <= '0';
    wait for 20 us;
    wait until rising_edge(distanceStart);
    wait for 20 us;
    distancePulse <= '1';
    wait for tbRangerDistance * clockPeriod;
  end process;

END ARCHITECTURE test;
