library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity CLKdetect is
    Port (       
						clk				:	in std_logic;	
						clkFix			:	in std_logic;					
						detectOutI  	: 	out std_logic_vector(15 downto 0);
						detectOutQ  	: 	out std_logic_vector(15 downto 0);
						reset				: 	in std_logic;					
						dataI				: 	in std_logic_vector(15 downto 0);
						dataQ				: 	in std_logic_vector(15 downto 0)
			);					

end CLKdetect;

architecture rtl of CLKdetect is

component qadd
	generic(Q : integer; N : integer);
	port (
   a : in std_logic_vector (15 downto 0);
	b : in std_logic_vector (15 downto 0);
	c : out std_logic_vector (15 downto 0)
);
end component;

signal sign : std_logic;
signal sr0:	std_logic_vector(15 downto 0):=x"0000";
signal sr1:	std_logic_vector(15 downto 0):=x"0000";
signal buf:	std_logic_vector(15 downto 0):=x"0000";
signal fromFix:	std_logic_vector(15 downto 0):=x"0000";

begin

sign <= not sr1(15);

	clk_process: process(clk,reset)
	begin	
		if reset = '1' then
			sr0 <= x"0000";
			sr1 <= x"0000";
		elsif rising_edge(clk) then
			sr1 <= sr0;
			sr0<= dataI;
			buf<= fromFix;
		end if;	
	end process;
	
	clkFix_process: process(clkFix)
	begin	
		if rising_edge(clkFix) then
			detectOutI <= buf;
		end if;	
	end process;
	

	
	adder : qadd
	generic map(Q=>9, N=>16)
		port map 
		(
		a	=>  sr0,
		b(14 downto 0) => sr1(14 downto 0),
		b(15) => sign,
		c => fromFix --detectOutI --fromFix

		);

end rtl;