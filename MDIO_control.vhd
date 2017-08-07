-- A Mealy machine has outputs that depend on both the state and
-- the inputs.	When the inputs change, the outputs are updated
-- immediately, without waiting for a clock edge.  The outputs
-- can be written more than once per state or per clock cycle.

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity mdio_control is

	port
	(
		clk	: in	std_logic;
		reset	 : in	std_logic;
		enable	: in std_logic;
		datain : in std_logic_vector(15 downto 0);
		convertion : out std_logic;
		dataout : out std_logic_vector(15 downto 0);
		opcode : out std_logic_vector(1 downto 0);
		NcoEn : out std_logic;
		RegNum : out std_logic_vector(4 downto 0)	
	);
	
end entity;

architecture rtl of mdio_control is

	-- Build an enumerated type for the state machine
	type state_type is (Reg20Write,Reg22write, Reg27write, Reg4write, Reg0write, resetwrite,IDLE);
	
	-- Register to hold the current state
	signal state : state_type;
	signal cnt : std_logic_vector(12 downto 0):="0000000000000";
	signal cntCycles : std_logic_vector(7 downto 0):="00000000";
	signal dataReg : std_logic_vector(15 downto 0):=x"0000";
	


begin
	process (clk, reset)
	begin
		if reset = '1' then
			state <= Reg22write;
			cnt<="0000000000000";
			cntCycles <= x"00";
			NcoEn<= '0';

		elsif (rising_edge(clk)) then
		if (enable = '1') then
			case state is
			
			when Reg20write=>
				NcoEn<= '0';
				cnt <=cnt+1;
				opcode <= "01";
				RegNum <= "10100";
				dataout <= x"0050";   --speed 100 x"0050";
				
				if (cnt="0000000000001") then 
					convertion <= '1';	
				end if;				
				if (cnt="0000000000010")then 
					convertion <= '0';
				end if;
				
					if (cnt="0000111111111") then
						state <= Reg22write;
						cnt<="0000000000000";
					else
						state <= Reg20write;
					end if;
			--
				when Reg22write=>
				NcoEn<= '0';
				cnt <=cnt+1;
				opcode <= "01";
				RegNum <= "10110";
				dataout <= x"800F";
				
				if (cnt="0000000000001") then 
					convertion <= '1';	
				end if;				
				if (cnt="0000000000010")then 
					convertion <= '0';
				end if;
				
					if (cnt="0000111111111") then
						state <= Reg27write;
						cnt<="0000000000000";
					else
						state <= Reg22write;
					end if;
							
				when Reg27write=>
						cnt <=cnt+1;
						opcode <= "01";
						RegNum <= "11011";
						dataout <= x"001F"; --x"001F"
						
					if (cnt="0000000000001")then 
						convertion <= '1';	
					end if;			
					if (cnt="0000000000010")then 
						convertion <= '0'; 
					end if;
						
						if (cnt="0000111111111") then
							state <= Reg4write;
							cnt<="0000000000000";
						else
							state <= Reg27write;
						end if;
					
				when Reg4write =>			
						cnt <=cnt+1;
						opcode <= "01";
						RegNum <= "00100";
						dataout <= x"0" & "0101" & "0101" & "0001";  -- en tx disable rx  --x"0DE1"  -0x0551 stable
						
					if (cnt="0000000000001")then 
						convertion <= '1';
					end if;			
					if (cnt="0000000000010")then 
						convertion <= '0'; 
					end if;
				
					if (cnt="0000111111111") then
						state <= Reg0write;
						cnt<="0000000000000";
					else
						state <= Reg4write;
					end if;


				when Reg0write =>
				--------------------------
-- REGISTER 0				enum {
--1181         PHY_CT_RESET    = 1<<15, /* Bit 15: (sc)        clear all PHY related regs */
--1182         PHY_CT_LOOP     = 1<<14, /* Bit 14:     enable Loopback over PHY */
--1183         PHY_CT_SPS_LSB  = 1<<13, /* Bit 13:     Speed select, lower bit */   					100 Mbps */
--1184         PHY_CT_ANE      = 1<<12, /* Bit 12:     Auto-Negotiation Enabled */
--1185         PHY_CT_PDOWN    = 1<<11, /* Bit 11:     Power Down Mode */
--1186         PHY_CT_ISOL     = 1<<10, /* Bit 10:     Isolate Mode */
--1187         PHY_CT_RE_CFG   = 1<<9, /* Bit  9:      (sc) Restart Auto-Negotiation */
--1188         PHY_CT_DUP_MD   = 1<<8, /* Bit  8:      Duplex Mode */
--1189         PHY_CT_COL_TST  = 1<<7, /* Bit  7:      Collision Test enabled */
--1190         PHY_CT_SPS_MSB  = 1<<6, /* Bit  6:      Speed select, upper bit */  					 1000 Mbps */

-- 1194         PHY_CT_SP1000   = PHY_CT_SPS_MSB, /* enable speed of 1000 Mbps */
--1195         PHY_CT_SP100    = PHY_CT_SPS_LSB, /* enable speed of  100 Mbps */
--1196         PHY_CT_SP10     = 0,              /* enable speed of   10 Mbps */
--1191 };
				--------------------------
					cnt <=cnt+1;
					opcode <= "01";
					RegNum <= "00000";
					dataout <= "0001" & "0001" & "0110"  & "0000";  --"0001" & "0001" & "0110"  & "0000"; --0x1140 5140  1160 -stable
						
				if (cnt="0000000000001")then 
					convertion <= '1';		
				end if;		
				if (cnt="0000000000010")then 
					convertion <= '0';		
				end if;
				
						if (cnt="0000111111111") then
							state <= resetwrite;
							cnt<="0000000000000";
						else
							state <= Reg0write;
						end if;
						
				when resetwrite =>
					cnt <=cnt+1;
					opcode <= "01";
					RegNum <= "00000";
					dataout <= "1001" & "0001" & "0110"  & "0000"; --  x"9160";  --0x9140 D140 x"9160"; - stable
						
	
						
						if (cnt="0000000000001")then 
							convertion <= '1';	
						end if;			
						if (cnt="0000000000010")then 
							convertion <= '0'; 
						end if;						
						
						if (cnt="0000111111111") then
							state <= IDLE;
							cnt<="0000000000000";
						else
							state <= resetwrite;
						end if;
						
				when IDLE =>
					state <= IDLE;
					cnt <=cnt+1;
					opcode <= "10";
					RegNum <= "00000";
						
						if (cnt="0000000000001")then 
							convertion <= '1';	
						end if;			
						if (cnt="0000000000010")then 
							convertion <= '0'; 
						end if;						
						
						if (cnt="1111111111111") then
							cnt<="0000000000000";
							cntCycles <= cntCycles + 1;
							if (cntCycles=x"1F") then
								NcoEn<= '1';
							end if;
						end if;

						
			end case;
		end if; -- enable	
		end if; --clk
	end process;
	
end rtl;

