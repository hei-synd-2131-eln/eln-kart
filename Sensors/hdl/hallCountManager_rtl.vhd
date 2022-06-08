--
-- VHDL Architecture Sensors.hallCountManager.rtl
--
-- Created:
--          by - axela.UNKNOWN (I12)
--          at - 14:19:51 24.05.2022
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

Library Kart;
	Use Kart.Kart.all;

ARCHITECTURE rtl OF hallCountManager IS

  function send_delta(pulses_x_2 : std_ulogic) return unsigned is
  begin
    if pulses_x_2 = '0' then
        return to_unsigned(SENS_HALLCOUNT_TURN_DELTA/2, 
          SENS_hallCountBitNb-SENS_HALL_CNT_BITNB);
    else
        return to_unsigned(SENS_HALLCOUNT_TURN_DELTA, 
          SENS_hallCountBitNb-SENS_HALL_CNT_BITNB);
    end if;
  end function;

  constant HALLDELTA : unsigned := send_delta(SENS_HALL_COUNTS_2PULSES_P_TURN);

  -- Register time between pulses to get approx. frequency
  type counterSetType is array(SENS_hallSensorNb-1 downto 0) of
    unsigned(SENS_HALL_CNT_BITNB-1 downto 0);

  signal p_counterSet: counterSetType;
  signal p_sendhall : std_ulogic_vector(SENS_hallSensorNb-1 downto 0);
  signal p_zerocnts : std_ulogic_vector(SENS_hallSensorNb-1 downto 0);

BEGIN

  sendHall <= p_sendhall;
  zeroHallCounters <= p_zerocnts;

	countCheck:process(reset, clock)
	begin
		if reset = '1' then
			p_zerocnts <= (others=>'0');
      p_counterSet <= (others=>(others=>'0'));
		elsif rising_edge(clock) then
			p_zerocnts <= (others=>'0');
			for index in 0 to SENS_hallSensorNb-1 loop
          -- Not a problem if we miss a pulse250us here
          if p_zerocnts(index) = '1' then
              p_counterSet(index) <= (others=>'0');
          -- When delta triggered, zero counters
          elsif hallCount(SENS_hallCountBitNb * (index + 1) - 1 
              downto 
              SENS_hallCountBitNb * index)
            >= HALLDELTA then
		      	p_zerocnts(index) <= '1';
          -- Count time within reaching number of pulses
          elsif pulse250us = '1' then
            p_counterSet(index) <= p_counterSet(index) + 1;
		      end if;
		    end loop;
		end if;
	end process;

  -- Setup register as 3 bits for nb 1/2 turns in 13bits * 0.25 us time

    -- If counts 2 pulses per turn (each hallPulse edge)
  sens_2pturn_on : if SENS_HALL_COUNTS_2PULSES_P_TURN = '1' generate
    hallregs : for index in 0 to SENS_hallSensorNb-1 generate

      setHallReg: process(reset, clock)
      begin
        if reset = '1' then
          hallReg(index) <= (hallReg(index)'range => '0');
          p_sendhall(index) <= '0';
        elsif rising_Edge(clock) then
          p_sendhall(index) <= '0';
          if p_zerocnts(index) = '1' then
            p_sendhall(index) <= '1';
            hallReg(index) <=
              dataRegisterType
              (
                unsigned'(
                  hallCount
                  (
                    SENS_hallCountBitNb * index
                      + (SENS_hallCountBitNb-SENS_HALL_CNT_BITNB) - 1
                    downto
                    SENS_hallCountBitNb * index
                  )
                  &  p_counterSet(index)
                )
              );
          end if;
        end if;
      end process setHallReg;

    end generate hallregs;
  end generate sens_2pturn_on;

    -- If counts 1 pulse per turn (each hallPulse rising edge)
  sens_2pturn_off : if SENS_HALL_COUNTS_2PULSES_P_TURN = '0' generate
    hallregs : for index in 0 to SENS_hallSensorNb-1 generate
      
      setHallReg: process(reset, clock)
      begin
        if reset = '1' then
          hallReg(index) <= (hallReg(index)'range => '0');
          p_sendhall(index) <= '0';
        elsif rising_Edge(clock) then
          p_sendhall(index) <= '0';
          if p_zerocnts(index) = '1' then
            p_sendhall(index) <= '1';
            hallReg(index) <=
              dataRegisterType
              (
                unsigned'(
                  hallCount
                  (
                    SENS_hallCountBitNb * index
                      + (SENS_hallCountBitNb-SENS_HALL_CNT_BITNB) - 2
                    downto
                    SENS_hallCountBitNb * index
                  )
                  & '0' & p_counterSet(index)
                )
              );
          end if;
        end if;
      end process setHallReg;

    end generate hallregs;
  end generate sens_2pturn_off;

END ARCHITECTURE rtl;