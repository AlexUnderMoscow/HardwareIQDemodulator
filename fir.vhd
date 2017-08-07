
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fir is
    Port ( dataCos : in  STD_LOGIC_VECTOR (15 downto 0);
				dataSin : in  STD_LOGIC_VECTOR (15 downto 0);
           clk : in  STD_LOGIC;
           hIn : in  STD_LOGIC_VECTOR (15 downto 0);
           hclk : in  STD_LOGIC;
			  alpha : out std_logic;
			  betta : out std_logic;
           cosOut : out  STD_LOGIC_VECTOR (15 downto 0);
			  sinOut : out  STD_LOGIC_VECTOR (15 downto 0)
			  );
end fir;

architecture Behavioral of fir is

component main
 generic (Order : integer; halfOrder : integer; Q : integer; N : integer);
port(
	clk : in std_logic;
	dataIn: in std_logic_vector(15 downto 0);
	clkh: in std_logic;
	hIn: in std_logic_vector(15 downto 0);
	outData : out std_logic_vector(15 downto 0);
	outLine : out std_logic 
);
end component;

signal toCosBus: std_logic_vector(15 downto 0); --15
signal toSinBus: std_logic_vector(15 downto 0);

begin

alpha <= toCosBus(15); --15
betta <= toSinBus(15);
cosOut<=toCosBus;
sinOut<=toSinBus;
toCosBus(14 downto 9) <= "000000"; 
toSinBus(14 downto 9) <= "000000"; 



cosFir : main
generic map(Order => 30, halfOrder => 15, Q =>9, N =>10)  --16
port map(
	clk => clk,
	dataIn(9) => dataCos(15),
	dataIn(8 downto 0) => dataCos(8 downto 0),
	clkh => hclk,
	hIn => hIn,
	outData(9) => toCosBus(15),
	outData(8 downto 0) => toCosBus(8 downto 0),
	outLine => open
);

sinFir : main
generic map(Order => 30, halfOrder => 15, Q =>9, N =>10)  --16
port map(
	clk => clk,
	dataIn(9) => dataSin(15),
	dataIn(8 downto 0) => dataSin(8 downto 0),
	clkh => hclk,
	hIn => hIn,
	outData(9) => toSinBus(15),
	outData(8 downto 0) => toSinBus(8 downto 0),
	outLine => open
);


end Behavioral;