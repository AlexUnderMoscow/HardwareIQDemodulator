library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity GUN is
generic (
			Len: integer := 16; 
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
end GUN;

architecture rtl of GUN is

component Reg
 generic (Len: integer; Address : std_logic_vector(7 downto 0));
port(
	clk : in std_logic;
	rst : in std_logic;
	Addr: in std_logic_vector(7 downto 0);
	Data: in std_logic_vector(Len-1 downto 0);
	outData : out std_logic_vector(Len-1 downto 0)
);
end component;

component tcv2bin
generic (WIDT: integer);
port(
	x		: in std_logic_vector(7 downto 0);
	y		: out std_logic_vector(7 downto 0)
);
end component;

component qadd
	generic(Q : integer; N : integer);
	port (
   a : in std_logic_vector (21 downto 0);
	b : in std_logic_vector (21 downto 0);
	c : out std_logic_vector (21 downto 0)
);
end component;

component nco is
port (	clk 		: in std_logic;
			ce			: in std_logic;
			reset 	: in std_logic;
			freq		: in unsigned(21 downto 0);
			phase 	: in unsigned(31 downto 0);
			sin	: out signed(7 downto 0);
			cos :out signed(7 downto 0)
);
end component;



	signal toFreqNcoLo: std_logic_vector(15 downto 0);
	signal toFreqNcoHi: std_logic_vector(15 downto 0);
	signal cosLine: std_logic_vector(7 downto 0);
	signal sinLine: std_logic_vector(7 downto 0);
	signal phase : unsigned(31 downto 0):=x"00000000";
	signal one : std_logic:='1';
	signal zero : std_logic_vector(31 downto 0):=x"00000000";
	signal toNCO: unsigned(21 downto 0);

begin

Reg2: Reg
 generic map(Len=>16, Address => Address1)	--02
port map( 
	clk => writeReg,
	rst => reset ,
	Addr => RegAddr,
	Data => RegData,
	outData => toFreqNcoLo
);

Reg3: Reg
 generic map(Len=>16, Address => Address2)		--03
port map(
	clk => writeReg,
	rst => reset ,
	Addr => RegAddr,
	Data => RegData,
	outData => toFreqNcoHi
);

	tcv2binSin : tcv2bin
	generic map(WIDT => 8)
	port map(
		x => sinLine,				--cosLine
		y => sin
	);
	
	tcv2binCos : tcv2bin
	generic map(WIDT => 8)
	port map(
		x => cosLine,				--cosLine
		y => cos
	);
	
	adder : qadd
	generic map(Q=>9, N=>22)
		port map 
		(

		a(21 downto 16) => toFreqNcoHi(5 downto 0),
		a(15 downto 0)	=>  toFreqNcoLo(15 downto 0),
		b => freqControl,
		c(21)			=>toNCO(21),
		c(20) 		=> toNCO(20),
		c(19) 		=> toNCO(19),
		c(18) 		=> toNCO(18),
		c(17) 		=> toNCO(17),
		c(16) 		=> toNCO(16),
		c(15) 		=> toNCO(15),
		c(14) 		=> toNCO(14),
		c(13) 		=> toNCO(13),
		c(12) 		=> toNCO(12),
		c(11) 		=> toNCO(11),
		c(10) 		=> toNCO(10),
		c(9) 		=> toNCO(9),
		c(8) 		=> toNCO(8),
		c(7) 		=> toNCO(7),
		c(6) 		=> toNCO(6),
		c(5) 		=> toNCO(5),
		c(4) 		=> toNCO(4),
		c(3) 		=> toNCO(3),
		c(2) 		=> toNCO(2),
		c(1) 		=> toNCO(1),
		c(0) 		=> toNCO(0)
		
		);
	
	nco1: nco 
	port map
	(
		clk =>  clk, --div(4)
		ce	=> one,
		reset => reset ,
		freq => toNCO,
		

		phase => phase	,															
		sin(7) => sinLine(7),
		sin(6) => sinLine(6),
		sin(5) => sinLine(5),
		sin(4) => sinLine(4),
		sin(3) => sinLine(3),
		sin(2) => sinLine(2),
		sin(1) => sinLine(1),
		sin(0) => sinLine(0),
		
		cos(7) => cosLine(7),	
		cos(6) => cosLine(6),	
		cos(5) => cosLine(5),
		cos(4) => cosLine(4),
		cos(3) => cosLine(3),
		cos(2) => cosLine(2),
		cos(1) => cosLine(1),
		cos(0) => cosLine(0)
	);

end rtl;