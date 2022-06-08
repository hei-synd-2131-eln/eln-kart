--
-- VHDL Architecture UART_test.serialTransmitter_tester.test
--
-- Created:
--          by - axel.amand
--          at - 20:18:36 11.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--


Library Kart;
  USE Kart.Kart.all;

LIBRARY std;
  USE std.textio.ALL;

library ieee;
  USE ieee.std_logic_textio.ALL;
  use ieee.math_real.all;

ARCHITECTURE test OF serialTransmitter_tester IS

  constant clockPeriod 	: time := 1.0/clockFrequency * 1 sec;
  signal sClock			: std_uLogic := '1';
  signal sReset         : std_uLogic ;

  constant rs232Frequency: real := real(UART_BAUD_RATE);
  constant rs232Period: time := (1.0/rs232Frequency) * 1 sec;

  signal rs232RxByte: unsigned(UART_BIT_NB-1 downto 0);

BEGIN

  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 0.9*clockPeriod;

  process
  begin
  	wait for 5 us;
    write(output,
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "-- Starting testbench" & lf &
      "--" &
      lf & lf
    );
    address <= symbolSizeType(to_unsigned(0, address'length));
    data <= dataRegisterType(to_unsigned(0, data'length));
    startSending <= '0';

    wait for 2*rs232Period;

  -- Standard sending, should trigger a pulse on registerFrame
  	address <= symbolSizeType(to_unsigned(16#25#, address'length));
    data <= dataRegisterType(to_unsigned(16#054f#, data'length));
    -- CRC <= 16#1e#;
    startSending <= '1', '0' after clockPeriod;
    wait until falling_edge(busySending);
    assert rs232RxByte = 16#1e#
      report "Bad CRC - should be 0x1E"
      severity failure;
    assert false
      report "Correct CRC 0x1E"
      severity note;

    wait for 4*rs232Period;

  -- Standard sending, should trigger a pulse on registerFrame
    address <= symbolSizeType(to_unsigned(16#c4#, address'length));
    data <= dataRegisterType(to_unsigned(16#1d52#, data'length));
    -- CRC <= 16#17#;
    startSending <= '1', '0' after clockPeriod;
    wait until falling_edge(busySending);
    assert rs232RxByte = 16#17#
      report "Bad CRC - should be 0x17"
      severity failure;
    assert false
      report "Correct CRC 0x17"
      severity note;

    wait for rs232Period;

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
