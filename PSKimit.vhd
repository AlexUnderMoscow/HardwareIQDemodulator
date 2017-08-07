library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity PSKimit is
    Port (       
						clk			:	in std_logic;						
						RegAddr  	: 	in std_logic_vector(7 downto 0);
						reset			: 	in std_logic;
						RegData		: 	in std_logic_vector(15 downto 0);
						PSK	 		: out std_logic_vector(15 downto 0);
						writeReg		:	in std_logic						
			);					
end PSKimit;

architecture rtl of PSKimit is

component GUN is
generic (
			Len: integer; 
			Address1 : std_logic_vector(7 downto 0); 
			Address2 : std_logic_vector(7 downto 0)
			);
    Port (       
						clk			:	in std_logic;
						reset			:	in std_logic;
						RegData		: 	in std_logic_vector(15 downto 0);
						RegAddr		: 	in std_logic_vector(7 downto 0);
						writeReg		:	in std_logic;
						freqControl	: 	in std_logic_vector(21 downto 0);
						sin			:	out std_logic_vector(7 downto 0);
						cos			:	out std_logic_vector(7 downto 0)
			  );
end component;

component CLKGen is
generic (
			Address1 : std_logic_vector(7 downto 0); 
			Address2 : std_logic_vector(7 downto 0)
			);
    Port (       
						clk			:	in std_logic;						
						clkOut  		: 	out std_logic;
						reset			: 	in std_logic;
						freqControl	: 	in std_logic_vector(21 downto 0);
						clkData		:	in std_logic;						
						data			: 	in std_logic_vector(15 downto 0);
						addr			: 	in std_logic_vector(7 downto 0)
			);					

end component;


	signal Gun1Cos : std_logic_vector(15 downto 0);
	signal Gun1Sin : std_logic_vector(15 downto 0);
	signal SymbolClock : std_logic;
	signal freqCLK : std_logic_vector(21 downto 0):="0000000000000000000000";
signal zero : std_logic:='0';
signal symbol : std_logic_vector(1 downto 0):="00";


begin

Gun1Cos(14 downto 7) <= x"00";
PSK(14 downto 0) <= Gun1Cos(14 downto 0);
PSK(15) <= Gun1Cos(15) xor symbol(0);

	clk_process: process(SymbolClock)
	begin	
		if rising_edge(SymbolClock) then
			symbol<=symbol+1;
		end if;	
	end process;
	




	GUN1: GUN
	generic map(Len=>16, Address1=>x"02", Address2=>x"03")
    port map(       
						clk			=> clk,
						reset			=>zero,
						RegData		=> RegData,
						RegAddr		=> RegAddr,
						writeReg		=> writeReg,
						freqControl => freqCLK,
						sin(6 downto 0)			=> Gun1Sin(6 downto 0),
						sin(7)						=> Gun1Sin(15),
						cos(7)						=> Gun1Cos(15),
						cos(6 downto 0)			=> Gun1Cos(6 downto 0) 
			  );	

			  
clock: CLKGen 
generic map(Address1=>x"0F", Address2=>x"10")
    port map(       
						clk								=>clk,					
						clkOut  							=>SymbolClock,
						reset								=>zero,
						freqControl 					=>freqCLK,						
						clkData							=>writeReg,					
						data								=>RegData,
						addr								=>RegAddr
			);	


	


end rtl;