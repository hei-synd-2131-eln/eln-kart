--
-- VHDL Architecture Sensors.batteryLevelSequencer.rtl
--
-- Created:
--          by - axel.amand.UNKNOWN (WE7860)
--          at - 17:19:58 19.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

library Common;
  use Common.CommonLib.all;

library Kart;
  use Kart.Kart.all;

ARCHITECTURE rtl OF batteryLevelSequencer IS

  constant sequenceLength : positive := 2*4 + 2*5;
  signal sequenceCounter: unsigned(requiredBitNb(sequenceLength)-1 downto 0);

  constant i2cWordBitNb: positive := 8;
  subtype i2cWordType is std_ulogic_vector(i2cWordBitNb-1 downto 0);
  constant i2cStart                     : i2cWordType := X"00";
  constant i2cStop                      : i2cWordType := X"FF";
  constant i2cRead                      : i2cWordType := X"FF";
  -- MCP3426
  constant mcpAddress              : i2cWordType := "11010000";

  -- Configuration register
  constant rdy : std_ulogic := '1';
    -- channel
  constant channel1 : std_ulogic_vector(1 downto 0) := "00";
  constant channel2 : std_ulogic_vector(1 downto 0) := "01";
    -- conversion mode, 1 = continuous, 0 = one-shot
  constant conversionMode : std_ulogic := '0';
    -- SR : 00 = 240 SPS (12bits), 01 = 60 SPS (14 bits), 10 = 15 SPS (16 bits)
    -- Check datasheet for how data is handled and modify storeData process
  constant sampleRate : std_ulogic_vector(1 downto 0) := "01";
    -- 00 = x1, 01 = x2, 10 = x4, 11 = x8
  constant gain : std_ulogic_vector(1 downto 0) := "00";

  -- Voltage (2B) and current (2B)
  constant readLength : positive := 3; -- 2B + null state

  signal startStop: std_ulogic;
  signal i2cWord: i2cWordType;
  signal ack: std_ulogic;

  
  signal readCounter: unsigned(requiredBitNb(readLength)-1 downto 0);
  signal p_volt_high, p_curr_high : unsigned(i2cWordBitNb-1 downto 0);
  signal p_volt, p_curr : unsigned(2*i2cWordBitNb-1 downto 0);

BEGIN

  --============================================================================
                                                          -- count send sequence
  countSequence: process(reset, clock)
  begin
    if reset = '1' then
      sequenceCounter <= (others => '0');
    elsif rising_edge(clock) then
      if sequenceCounter = 0 then
        if refresh = '1' then
          sequenceCounter <= sequenceCounter + 1;
        end if;
      else
        if txBusy = '0' then
          if sequenceCounter < sequenceLength then
            sequenceCounter <= sequenceCounter + 1;
          else
            sequenceCounter <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process countSequence;

  --============================================================================
                                                            -- send I2C commands
  sendI2cCommands: process(sequenceCounter)
  begin
    startStop <= '0';
    i2cWord <= (others => '0');
    ack <= '1';
    case to_integer(sequenceCounter) is
        -- Setup channel 1
      when  1 => startStop <= '1'; i2cWord <= i2cStart;
      when  2 => i2cWord <= mcpAddress;
      when  3 => i2cWord <= rdy & channel1 & conversionMode & sampleRate & gain;
      when  4 => startStop <= '0'; i2cWord <= i2cStop;
        -- Read channel 1
      when  5 => startStop <= '1'; i2cWord <= i2cStart;
      when  6 => i2cWord <= mcpAddress or X"01";
      when  7 => i2cWord <= i2cRead; ack <= '0';
      when  8 => i2cWord <= i2cRead; ack <= '0';
      when  9 => startStop <= '1'; i2cWord <= i2cStop;
        -- Setup channel 2
      when 10 => startStop <= '1'; i2cWord <= i2cStart;
      when 11 => i2cWord <= mcpAddress;
      when 12 => i2cWord <= rdy & channel2 & conversionMode & sampleRate & gain;
      when 13 => startStop <= '0'; i2cWord <= i2cStop;
        -- Read channel 2
      when 14 => startStop <= '1'; i2cWord <= i2cStart;
      when 15 => i2cWord <= mcpAddress or X"01";
      when 16 => i2cWord <= i2cRead; ack <= '0';
      when 17 => i2cWord <= i2cRead; ack <= '0';
      when 18 => startStop <= '1'; i2cWord <= i2cStop;
      when others => null;
    end case;
  end process sendI2cCommands;

  txData <= startStop & ack & i2cWord;
  txSend <= '1' when (sequenceCounter > 0) and (txBusy = '0')
    else '0';

  --============================================================================
                                                           -- read data from I2C
  ------------------------------------------------------------------------------
                                      -- read counter increments with input data
  readFSM: process(reset, clock)
  begin
    if reset = '1' then
      readCounter <= (others => '0');
    elsif rising_edge(clock) then
      -- start condition clears counter
      if (dataValid = '1') and (rxData(rxData'high) = '1') and
          (rxData(rxData'high-1) = '0') then
        readCounter <= (others => '0');
      -- chip address starts counting
      elsif readCounter = 0 then
        if (dataValid = '1') and (rxData(rxData'high-2 downto 0) = 
            (mcpAddress or X"01")) then
          readCounter <= readCounter + 1;
        end if;
      else
        if dataValid = '1' then
          -- acknowledge defines when to stop counter
          if rxData(rxData'high-1) = '0' then
            readCounter <= readCounter + 1;
          else
            readCounter <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process readFSM;

  ------------------------------------------------------------------------------
                                   -- store all high and then all low data bytes
  storeData: process(reset, clock)
  begin
    if reset = '1' then
      p_volt_high <= (others=>'0');
      p_curr_high <= (others=>'0');
      p_volt <= (others=>'0');
      p_curr <= (others=>'0');
    elsif rising_edge(clock) then
      if dataValid = '1' then
        case to_integer(readCounter) is
          when 1 =>
            if sequenceCounter < to_unsigned(10, sequenceCounter'length) then
              p_volt_high <= unsigned(rxData(i2cWordBitNb-1 downto 0));
            else
              p_curr_high <= unsigned(rxData(i2cWordBitNb-1 downto 0));
            end if;
          when 2 =>
            if sequenceCounter < to_unsigned(10, sequenceCounter'length) then
              p_volt <= "00" & p_volt_high(i2cWordBitNb-3 downto 0) & 
                unsigned(rxData(i2cWordBitNb-1 downto 0));
            else
              p_curr <= "00" & p_curr_high(i2cWordBitNb-3 downto 0) & 
                unsigned(rxData(i2cWordBitNb-1 downto 0));
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process storeData;

  battery250uv <= dataRegisterType(p_volt);
  current250uA <= dataRegisterType(p_curr);

END ARCHITECTURE rtl;
