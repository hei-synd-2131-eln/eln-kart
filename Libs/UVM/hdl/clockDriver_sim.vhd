LIBRARY std;
  USE std.TEXTIO.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF clockDriver IS
                                                                   -- parameters
  signal clockFrequency : real;
  signal clockPeriod: time := 10 ns;
  signal clock_int: std_ulogic := '1';

BEGIN
  ------------------------------------------------------------------------------
                                                        -- interpret transaction
  interpretTransaction: process(driverTransaction)
    variable myLine : line;
    variable commandPart : line;
    variable frequency_nat : natural;
  begin
    write(myLine, driverTransaction);
    rm_side_separators(myLine);
    read_first(myLine, commandPart);
    if commandPart.all = "clock_frequency" then
      read(myLine, frequency_nat);
      clockFrequency <= real(frequency_nat);
    end if;
    deallocate(myLine);
  end process interpretTransaction;

  clockPeriod <= 1.0/clockFrequency * 1 sec;

  --============================================================================
                                                                        -- clock
  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;
                                                                        -- reset
  driveReset: process
  begin
    reset <= '1';
    wait until clockPeriod'event;
    wait until clockPeriod'event;
    reset <= '0' after 2*clockPeriod;
    wait;
  end process driveReset;

END ARCHITECTURE RTL;
