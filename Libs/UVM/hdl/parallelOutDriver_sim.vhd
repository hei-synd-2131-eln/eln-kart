LIBRARY std;
  USE std.TEXTIO.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF parallelOutDriver IS

  signal parallelOut_int : std_ulogic_vector(parallelOut'range)
    := (others => '0');

BEGIN
  ------------------------------------------------------------------------------
                                                        -- interpret transaction
  interpretTransaction: process(driverTransaction)
    variable myLine : line;
    variable commandPart : line;
  begin
    write(myLine, driverTransaction);
    rm_side_separators(myLine);
    read_first(myLine, commandPart);
    if commandPart.all = command then
      parallelOut_int <= sscanf(myLine.all);
    end if;
    deallocate(myLine);
  end process interpretTransaction;

  parallelOut <= parallelOut_int;

END ARCHITECTURE RTL;
