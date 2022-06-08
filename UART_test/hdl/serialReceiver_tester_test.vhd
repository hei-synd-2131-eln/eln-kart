--
-- VHDL Architecture UART_test.serialReceiver_tester.test
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 10:07:38 11.05.2022
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

ARCHITECTURE test OF serialReceiver_tester IS

  constant clockPeriod 	: time := 1.0/clockFrequency * 1 sec;
  signal sClock			: std_uLogic := '1';
  signal sReset         : std_uLogic ;

  constant rs232Frequency: real := real(UART_BAUD_RATE);
  constant rs232Period: time := (1.0/rs232Frequency) * 1 sec;

  signal busAddress : natural;
  signal busData : natural;
  signal busSend: std_uLogic := '0';
  signal busSendDone: std_uLogic := '0';
  signal busCRC : integer;
  type commandType is array(1 to 5) of unsigned(7 downto 0);
  signal rs232Command : commandType;
  signal rs232SendCommand: std_uLogic := '0';
  signal rs232SendCommandDone: std_uLogic;
  signal rs232RxByte: unsigned(UART_BIT_NB-1 downto 0);
  signal rs232SendRxByte: std_uLogic := '0';
  signal rs232TxByte: unsigned(UART_BIT_NB-1 downto 0);
  signal rs232OmitByte : std_ulogic := '0';
  signal sendingIndication : std_ulogic;

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

  wait for 2*rs232Period;

  -- Standard sending, should trigger a pulse on registerFrame
  	rs232OmitByte <= '0';
  	busAddress <= 16#25#;
    busData <= 16#054f#;
    busCRC <= 16#1e#;
    busSend <= '1', '0' after 1 ns;
    wait until rising_edge(busSendDone);

  wait for 30*rs232Period;

  -- Omit a byte to trigger the watchdog, should reset state and counter
  	rs232OmitByte <= '1';
  	busAddress <= 16#25#;
    busData <= 16#054f#;
    busCRC <= 16#1e#;
    busSend <= '1', '0' after 1 ns;
    wait until rising_edge(busSendDone);

  wait for 30*rs232Period;
  
    -- Put wrong CRC value, should not trigger a pulse on registerFrame
  	rs232OmitByte <= '0';
  	busAddress <= 16#25#;
    busData <= 16#054f#;
    busCRC <= 16#43#;
    busSend <= '1', '0' after 1 ns;
    wait until rising_edge(busSendDone);

  -- End
	assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;


  ------------------------------------------------------------------------------

  sendCommand: process
    variable dataUnsigned: natural;
  begin
    busSendDone <= '1';
    rs232Command(1) <= to_unsigned(16#AA#, rs232Command(1)'length);

    wait until rising_edge(busSend);
    busSendDone <= '0';
    dataUnsigned := to_integer(
      unsigned(
        to_signed(busData, 2*UART_BIT_NB)
      )
    );

    rs232Command(5) <= to_unsigned(busCRC, rs232Command(5)'length);
    rs232Command(2) <= to_unsigned(busAddress, rs232Command(2)'length);
    rs232Command(3) <= to_unsigned(dataUnsigned / 2**8, rs232Command(3)'length);
    rs232Command(4) <= to_unsigned(dataUnsigned mod 2**8, rs232Command(4)'length);
    wait for 1 ns;
    rs232SendCommand <= '1', '0' after 1 ns;
    
    wait until rising_edge(rs232SendCommandDone);

  end process sendCommand;

    ------------------------------------------------------------------------------
                                                            -- RS232 send serial
  rxSendString: process
    constant rs232BytePeriod : time := 15*rs232Period;
    variable stringRight: natural;
  begin

    rs232SendCommandDone <= '1';

    wait until rising_edge(rs232SendCommand);
    rs232SendCommandDone <= '0';

    for index in rs232Command'range loop
      if rs232OmitByte = '0' or index /= rs232command'high then
	      rs232RxByte <= rs232Command(index);
	      rs232SendRxByte <= '1', '0' after 1 ns;
	  end if;
      wait for rs232BytePeriod;
    end loop;

  end process rxSendString;

  rsSendByte: process
    variable rxData: unsigned(UART_BIT_NB-1 downto 0);
  begin
  	sendingIndication <= '0';
    RxD <= '1';

    wait until rising_edge(rs232SendRxByte);
    rxData := rs232RxByte;

    RxD <= '0';
    wait for rs232Period;

    for index in rxData'reverse_range loop
      sendingIndication <= '1' after rs232Period/2, '0' after rs232Period/2 + clockPeriod;
      RxD <= rxData(index);
      wait for rs232Period;
    end loop;

  end process rsSendByte;

END ARCHITECTURE test;

