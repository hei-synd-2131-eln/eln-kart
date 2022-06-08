LIBRARY std;
  USE std.textio.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF driverControl IS

  signal testInfo: string(driverTransaction'range) := (others => ' ');

BEGIN
  ------------------------------------------------------------------------------
                                                         -- interpret frame file
  parseFile: process
    file driverFile : text;
    variable driverLine : line;
    variable preComment : line;
    variable command : line;
    variable delay : time;
    variable address : line;
  begin
    driverTransaction <= pad("idle", driverTransaction'length);
    if verbosity > 0 then
      print("Opening driver sequence file " & driverFileSpec);
    end if;

    file_open(driverFile, driverFileSpec, READ_MODE);
    while not endfile(driverFile) loop
      readline (driverFile, driverLine);
      read_first(driverLine, "#", preComment);
      driverLine := preComment;
      trim_line(driverLine);
      if driverLine.all'length > 0 then
        --lc(driverLine);
        if verbosity > 1 then
          print(driverLine.all);
        end if;
        read_first(driverLine, command);
        if verbosity > 1 then
          print(command.all & ":" & driverLine.all);
        end if;

        if command.all = "info" then
          if verbosity > 0 then
            print("Info: " & driverLine.all);
          end if;
          testInfo <= pad(driverLine.all, testInfo'length);

        elsif command.all = "at" then
          if verbosity > 0 then
            print(cr & "Advancing simulation to time " & driverLine.all);
          end if;
          delay := sscanf(driverLine.all);
          wait for delay - now;

        elsif command.all = "wait" then
          if verbosity > 0 then
            print(cr &"Advancing simulation of step " & driverLine.all);
          end if;
          delay := sscanf(driverLine.all);
          wait for delay;

        else
          driverTransaction <= pad(" ", driverTransaction'length);
          wait for 0 ns;
          driverTransaction <= pad(
            command.all & " " & driverLine.all,
            driverTransaction'length
          );
          if verbosity > 0 then
            print(command.all & " " & driverLine.all);
          end if;
        end if;

      end if;
    end loop;
    file_close(driverFile);

    wait;
  end process parseFile;

END ARCHITECTURE RTL;
