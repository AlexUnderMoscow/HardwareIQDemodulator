-- The MDIO serial control interface allows communication be-
-- tween a station management controller and SCAN25100 de-
-- vices. MDIO and MDC pins are 3.3V LVTTL compliant, not
-- 1.2V compatiable. It is software compatible with the station
-- management bus defined in IEEE 802.3ae-2002. The serial
-- control interface consists of two pins, the data clock MDC and
-- bidirectional data MDIO. MDC has a maximum clock rate of
-- 2.5 MHz and no minimum limit. The MDIO is bidirectional and
-- can be shared by up to 32 physical devices.

-- The MDIO pin requires a pull-up resistor which, during IDLE
-- and turnaround, will pull MDIO high. The parallel equivalence
-- of the MDIO when shared with other devices should not be
-- less than 1.5 k?. Note that with many devices in parallel, the
-- internal pull-up resistors add in parallel. Signal quality on the
-- net should provide incident wave switching. It may be desir-
-- able to control the edge rate of MDC and MDIO from the
-- station management controller to optimize signal quality de-
-- pending upon the trace net and any resulting stub lengths.

-- In order to initialize the MDIO interface, the station manage-
-- ment sends a sequence of 32 contiguous logic ones on MDIO
-- with MDC clocking. This preamble may be generated either
-- by driving MDIO high for 32 consecutive MDC clock cycles,
-- or by simply allowing the MDIO pull-up resistor to pull the
-- MDIO high for 32 MDC clock cycles. A preamble is required
-- for every operation (64-bit frames, do not suppress preambles).
-- MDC is an a periodic signal. Its high or low duration is 160 ns
-- minimum and has no maximum limit. Its period is 400 ns min-
-- imum. MDC is not required to maintain a constant phase
-- relationship with TXCLK, SYSCLK, and REFCLK. The follow-
-- ing table shows the management frame structure in according
-- to IEEE 802.3ae.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use work.modules.all;
USE ieee.std_logic_unsigned.ALL;

entity mdio is
   generic (
   	mdio_address    : std_logic_vector(4 downto 0):="10000"
  -- 	device_address  : std_logic_vector(4 downto 0):="11011"  
   );
	

	
   port (
   reset					: in std_logic;
	clk_in 				: in std_logic; -- deve essere < 2.5 MHz!
	serial_clock    	: out std_logic := '0'; -- deve essere < 2.5 MHz!
	serial_data     	: inout std_logic;
	device_address    : in std_logic_vector (4 downto 0);

	-- 00: Address
        -- 10: Read-Inc
	-- 11: Read
        -- 01: Write
	opcode  					: in std_logic_vector(1 downto 0);
	data_read      		 : out std_logic_vector(15 downto 0);
	data_write     		 : in std_logic_vector(15 downto 0);
	start_conversion		: in std_logic;
	running_conversion  	: out std_logic;
	error_code          	: out std_logic_vector(2 downto 0)

   );
end entity mdio;

architecture rtl of mdio is

   type tipo_stato is ( WaitStart, WaitStart2, Preamble, StartOpcode, MdioAddress, DeviceAddress, TurnAroundDataRead, TurnAroundDataWrite, DataRead, DataWrite );
   signal start_opcode : std_logic_vector(3 downto 0);

   signal stato       	: tipo_stato := WaitStart;
   signal start_conversion_loc : std_logic := '0';
   signal clock : std_logic:='0';
   signal serial_trigger : std_logic := '0';

begin
   start_opcode <= "01" & opcode;

--    with stato select led(3 downto 1) <=
-- 	"000" when WaitStart,
-- 	"001" when Preamble,
-- 	"010" when StartOpcode,
-- 	"011" when MdioAddress,
-- 	"100" when DeviceAddress,
-- 	"110" when DataWrite,
-- 	"111" when DataRead,
-- 	"101" when OTHERS;

   process(clk_in)
   begin
      if rising_edge(clk_in) then
         clock <= not clock;
      end if;
   end process;

    serial_clock <= clock;
	

    process(clk_in)
    begin
       if falling_edge(clk_in) then
          serial_trigger <= not serial_trigger;
       end if;
    end process;

   -- process(serial_trigger, reset)
   process(serial_trigger, reset)
      variable bit_counter : natural range 0 to 31 := 0;
   begin
      
      if reset = '1' then
	 stato <= WaitStart;
	 bit_counter := 0;
	 start_conversion_loc <= start_conversion;
	 running_conversion <= '0';
	 error_code <= "000";
	 serial_data <= 'Z';

      else 

	 -- if falling_edge(serial_trigger) then
	 if falling_edge(serial_trigger) then

	    case stato is

	       when WaitStart =>
		  serial_data <= 'Z';
		  stato <= WaitStart2;
		  
	       when WaitStart2 =>



		  if start_conversion /= start_conversion_loc then
		     start_conversion_loc <= start_conversion;
		     bit_counter := 31;
		     stato <= Preamble;
		     running_conversion <= '1';
		     error_code <= "000";
	          else
		     running_conversion <= '0';
		  end if;

	       when Preamble =>
		  -- serial_data <= '1';

		  if serial_data = '0' then

		     stato <= WaitStart;
                  else
		     if bit_counter > 0 then
		        bit_counter := bit_counter - 1;
		     else
   		        stato <= StartOpcode;
		        bit_counter := 3;
		     end if;
		  end if;

	       when StartOpcode =>
		  serial_data <= start_opcode(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= MdioAddress;
		     bit_counter := 4;
		  end if;

	       when MdioAddress =>
		  serial_data <= mdio_address(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= DeviceAddress;
		     bit_counter := 4;
		  end if;

	       when DeviceAddress =>
		  serial_data <= device_address(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     if opcode(1) = '1' then
			stato <= TurnAroundDataRead;
		     else
			stato <= TurnAroundDataWrite;
		     end if;
		  end if;

	       when TurnAroundDataWrite =>
		  if bit_counter = 0 then
		     serial_data <= '1';
		     bit_counter := 15;
		  else 
		     serial_data <= '0';
		     stato <= DataWrite;
		  end if;

	       when DataWrite =>
		  serial_data <= data_write(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= WaitStart;
		  end if;

	       when TurnAroundDataRead =>
		  serial_data <= 'Z';
		  
		  if bit_counter = 0 then
  	             bit_counter := 15;
		  else

 	             if serial_data = '0' then
		        stato <= DataRead;
		     else
		        stato <= WaitStart; -- ERRORE!
		        -- stato <= DataRead;
		        error_code <= "001";

		     end if;
                  end if;

	       when DataRead =>
	          data_read(bit_counter) <= serial_data;

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= WaitStart;
		  end if;
		  
	       when others =>
		  stato <= WaitStart;
 		  serial_data <= 'Z';
		  error_code <= "111";


	    end case;
	 end if;
      end if; -- if reset
   end process;

end rtl;
