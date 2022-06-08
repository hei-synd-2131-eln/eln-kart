--
-- VHDL Architecture Kart_test.txFIFO_tester.test
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 08:09:37 12.05.2022
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

ARCHITECTURE test OF txFIFO_tester IS

  constant clockPeriod  : time := 1.0/CLOCK_FREQUENCY * 1 sec;
  signal sClock     : std_uLogic := '1';
  signal sReset         : std_uLogic ;

  constant rs232Frequency: real := real(UART_BAUD_RATE);
  constant rs232Period: time := (1.0/rs232Frequency) * 1 sec;

  signal rs232RxByte: unsigned(UART_BIT_NB-1 downto 0);

  signal testInfo       : string(1 to 40) := (others => ' ');

BEGIN

  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 0.9*clockPeriod;

  process
  begin
    testInfo <= pad("TXFifo Test Bench", testInfo'length);
    address <= symbolSizeType(to_unsigned(0, address'length));
    data <= dataRegisterType(to_unsigned(0, data'length));
    load <= '0';

    wait for 5 us;
    write(output,
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "-- Starting testbench" & lf &
      "--" &
      lf & lf
    );
    wait until rising_edge(clock);

    -- Load memory quick and too much, so full should be 1 and last not
      -- registered
    testInfo <= pad("Feeding queue", testInfo'length);
    for i in 0 to queueSize loop
      address <= symbolSizeType(to_unsigned(i+1, address'length));
      data <= dataRegisterType(to_unsigned(i+1, data'length));
      wait until rising_edge(clock);
      load <= '1';
      wait until rising_edge(clock);
      load <= '0';
      wait for 10*clockPeriod;
    end loop;
    assert full = '1'
      report "FIFO should be full"
      severity failure;
    assert false
      report "FIFO full detection OK"
      severity note;

    testInfo <= pad("Waiting for empty", testInfo'length);
    for i in 1 to queueSize loop
      wait until falling_edge(busySending);
    end loop;
    testInfo <= pad("Empty, waiting a bit", testInfo'length);
    wait for 10000*clockPeriod;

    testInfo <= pad("Feeding half", testInfo'length);
    -- Send again
    for i in 0 to queueSize/2 loop
      address <= symbolSizeType(to_unsigned(2*(i+1), address'length));
      data <= dataRegisterType(to_unsigned(2*(i+1), data'length));
      wait until rising_edge(clock);
      load <= '1';
      wait until rising_edge(clock);
      load <= '0';
      wait for 10*clockPeriod;
    end loop;

    testInfo <= pad("Waiting for empty", testInfo'length);
    for i in 0 to queueSize/2 loop
      wait until falling_edge(busySending);
    end loop;
    testInfo <= pad("Empty, waiting a bit", testInfo'length);
    wait for 10000*clockPeriod;

    -- Overfeeding, should not be able to send everything
    testInfo <= pad("Overfeeding queue", testInfo'length);
    for i in 0 to 2*queueSize loop
      address <= symbolSizeType(to_unsigned(i+1, address'length));
      data <= dataRegisterType(to_unsigned(i+1, data'length));
      wait until rising_edge(clock);
      load <= '1';
      wait until rising_edge(clock);
      load <= '0';
      wait for 10*clockPeriod;
    end loop;
    assert full = '1'
      report "FIFO should be full"
      severity failure;
    assert false
      report "FIFO full detection OK"
      severity note;

    testInfo <= pad("Waiting for empty", testInfo'length);
    for i in 1 to queueSize loop
      wait until falling_edge(busySending);
    end loop;
    wait for 10000*clockPeriod;

    -- End
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

  ------------------------------------------------------------------------------
                                                           -- RS232 receive byte
  rsReceiveByte: process
    variable txData: unsigned(UART_BIT_NB-1 downto 0);
  begin
    wait until falling_edge(TxD);

    wait for 1.5 * rs232Period;

    for index in txData'reverse_range loop
      txData(index) := TxD;
      wait for rs232Period;
    end loop;

    rs232RxByte <= txData;

  end process rsReceiveByte;


END ARCHITECTURE test;
