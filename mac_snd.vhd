library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.PCK_CRC32_D4.all;
--use work.common.all;

entity mac_snd is
   port(   
		phen 					: out std_logic;	
      E_TX_CLK 			: in  std_logic;                       -- Sender Clock.
      E_TX_EN  			: out std_logic;                       -- Sender Enable.
      E_TXD   				 : out std_logic_vector(3 downto 0);    -- Sent Data.
		addr					: out std_logic_vector(7 downto 0);				 --7
      dataI  				: in  std_logic_vector(15 downto 0);    --
		dataQ  				: in  std_logic_vector(15 downto 0);    --
		clkRead					:out std_logic;
      en       			: in  std_logic                        -- User Start Send. 
   );
end mac_snd;

architecture rtl of mac_snd is

   type mem_t is array(0 to 41) of std_logic_vector(7 downto 0);
   
   signal mem : mem_t := (
     --------------------------------------------------------------------------
      -- Host PC MAC Address                                                  --
      --------------------------------------------------------------------------
      -- 0x0 - 0x5
		
		x"88", x"AE", x"1D", x"40", x"7B", x"2A",
		x"DC", x"0E", x"A1", x"57", x"50", x"30",
	
																		--	x"88", x"AE", x"1D", x"40", x"7B", x"2A",
																		--x"DC", x"0E", x"A1", x"57", x"50", x"30",
      
      x"08", x"00",						-- EtherType Field
		x"45",								--version and header length
		x"00",								--diferental services
		x"04",x"1C",						--total length 1052 - 1056 bytes 041c
		x"7C",x"43",   					--identification 						~~~~~
		x"40",								--flags
		x"00",								--fragment offset
		x"40",								--TTL = 128
		x"11",								--Protocol = UDP 17  =  11H
		x"CC",x"5A",						--header checksum
		x"AC",x"11",x"4B",x"0F",		--IP addr source = 172.17.75.15
		x"AC",x"11",x"4B",x"01",		--IP addr destination = 172.17.75.1
		x"D0",x"11",						--source port = 58 841
		x"13",x"89",						--dest port = 5011
		x"04",x"08",						--Length = 1032 1034
		x"00",x"00"							--CRC

   );

 --  attribute RAM_STYLE : string;
 --  attribute RAM_STYLE of mem: signal is "BLOCK";

   type state_t is (
      Idle,                      -- Wait for signal en.
      Preamble,                  -- 55 55 55 55 55 55 55 5
      StartOfFrame,              -- d
      Upper,                     -- Send upper Nibble
      Lower,                     -- Send lower Nibble
		
	--	packetNumberU,					--контроль потерь пакетов
	--	packetNumberL,					--контроль потерь пакетов
		
      dataIstate,             -- Send 
		dataQstate,
      FrameCheck,                -- No Frame Check for now.
      InterframeGap              -- Gap between two cosecutive frames (93 Bit).
   );
   

     signal s   : state_t:=Idle;
     signal crc : std_logic_vector(31 downto 0):=(others => '1');   -- CRC32 latch.
     signal c   : integer:=0;
     signal a   : integer:=0;
	  signal cntAddr : std_logic_vector(7 downto 0):="00000000"; --8
	  signal packNumber : std_logic_vector(15 downto 0):=(others => '0');   -- контроль целостности
	  
begin

	addr <= cntAddr;
	
   snd_nsl : process(E_TX_CLK)
   begin
    if rising_edge(E_TX_CLK) then

      E_TX_EN <= '0';
      E_TXD   <= x"0"; 
		phen <= '0';		
      case s is
         when Idle =>
			cntAddr<=cntAddr;
			

				E_TX_EN <= '0';
				E_TXD   <= x"0"; 
				phen <= '0';
				if (en = '1') then
					c <= 0;
               s <= Preamble;
				end if;
         -----------------------------------------------------------------------
         -- Ethernet II - Preamble and Start Of Frame.                        --
         -----------------------------------------------------------------------            
         when Preamble =>
				cntAddr<=cntAddr;

            E_TXD   <= x"5";
            E_TX_EN <= '1';
				phen <= '0';
            if c = 14 then
               c <= 0;
               s <= StartOfFrame;
            else
               c <= c + 1;
            end if;
            
         when StartOfFrame =>
				cntAddr<=cntAddr;

            E_TXD   <= x"d";
				c <= 0;
				phen <= '0';
            E_TX_EN <= '1';
            crc <= x"ffffffff";
            s   <= Upper;

         -----------------------------------------------------------------------
         -- Custom Protocol Transmit.                                         --
         -----------------------------------------------------------------------            
         when Upper =>
				cntAddr<=cntAddr;
				phen <= '0';
            E_TXD   <= mem(c)(3 downto 0);
            E_TX_EN <= '1';
            crc <= nextCRC32_D4(mem(c)(3 downto 0), crc);
            s   <= Lower;
         
         when Lower =>
				cntAddr<=cntAddr;
				phen <= '0';
            E_TXD   <= mem(c)(7 downto 4);
            E_TX_EN <= '1';
            crc <= nextCRC32_D4(mem(c)(7 downto 4), crc);   
            if c = 41 then
               c <= 0;
               s <= dataIstate; --dataIU; --packetNumberU; 
            else
               c <= c + 1;
               s <= Upper;
            end if;            


            
--				when packetNumberU =>
--				cntAddr<="00000000";
--				phen <= '0';
 --           E_TXD   <= packNumber(4*c+3 downto 4*c);
 --           E_TX_EN <= '1';

--            crc <= nextCRC32_D4(packNumber(4*c+3 downto 4*c), crc); 
--            if c = 1 then
--               c <= 0;
--               s <= packetNumberL;
--            else
--               c <= c + 1;
 --           end if;
--				
--				when packetNumberL =>
--				cntAddr<="00000000";
--				phen <= '0';
--            E_TXD   <= packNumber(4*c+11 downto 4*c+8);
 --           E_TX_EN <= '1';

 --           crc <= nextCRC32_D4(packNumber(4*c+11 downto 4*c+8), crc); 
 --           if c = 1 then
 --              c <= 0;
 --              s <= dataIU; --dataQU
 --           else
 --              c <= c + 1;
 --           end if;
			-----------------------------------------------------------------------
         --                             --
			-----------------------------------------------------------------------
         when dataIstate =>
				phen <= '0';
				clkRead <= '0';
				cntAddr<=cntAddr;
            E_TXD   <= dataI(4*c+3 downto 4*c);
            E_TX_EN <= '1';

            crc <= nextCRC32_D4(dataI(4*c+3 downto 4*c), crc); 
            if c = 3 then
               c <= 0;
               s <= dataQstate;
            else
               c <= c + 1;
            end if;            
         

         when dataQstate =>		
				phen <= '0';
            E_TXD   <= dataQ(4*c+3 downto 4*c);
            E_TX_EN <= '1';
            crc <= nextCRC32_D4(dataQ(4*c+3 downto 4*c), crc); 
            if c = 3 then
               c <= 0;
					cntAddr <= cntAddr+1;
					clkRead <= '1';
					if cntAddr = x"FF" then   --511
                  s <= FrameCheck;
               else
                  s <= dataIstate;
               end if;
            else
					clkRead <= '0';
               c <= c + 1;
					cntAddr<=cntAddr;
            end if;

				----
            		
         -----------------------------------------------------------------------
         -- Ethernet II - Frame Check.                                        --
         -----------------------------------------------------------------------            
         when FrameCheck =>
				cntAddr<=cntAddr;
				clkRead <= '0';
				phen <= '0';
            E_TXD   <= not crc(4*c+3 downto 4*c);
            E_TX_EN <= '1';
            if c = 7 then
               c <= 0;
               s <= InterframeGap;
            else
               c <= c + 1;
            end if;

         -----------------------------------------------------------------------
         -- Ethernet II - Interframe Gap.                                     --
         -----------------------------------------------------------------------            
         when InterframeGap =>	
				cntAddr<=cntAddr;	
            if c = 23 then
               c <= 0;
					phen <= '0';
               s <= Idle;
            else
               c <= c + 1;
					phen <= '1';
            end if;
      end case;
		end if; --rising 
   end process;
	

	
end rtl;
     
