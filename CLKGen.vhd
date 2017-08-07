library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity CLKGen is
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

end CLKGen;

architecture rtl of CLKGen is

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

component nco is
port (	clk 		: in std_logic;
			ce			: in std_logic;
			reset 	: in std_logic;
			freq		: in unsigned(21 downto 0);
			phase 	: in unsigned(31 downto 0);
			sin		: out signed(7 downto 0);
			cos 		:out signed(7 downto 0)
);
end component;

component qadd
	generic(Q : integer; N : integer);
	port (
   a : in std_logic_vector (22 downto 0);
	b : in std_logic_vector (22 downto 0);
	c : out std_logic_vector (22 downto 0)
);
end component;

signal acc: unsigned(31 downto 0):=x"00000000";
signal phase : unsigned(31 downto 0):=x"00000000";
signal one : std_logic:='1';
signal zero : std_logic:='0';
signal toFreqNcoLo: std_logic_vector(15 downto 0);
signal toFreqNcoHi: std_logic_vector(15 downto 0);
signal toNCO: unsigned(21 downto 0);
signal cosLine: std_logic;
signal sr2:	std_logic_vector(1 downto 0):="00";

begin


	clk_process: process(clk)
	begin	
		if rising_edge(clk) then
			sr2(1) <= sr2(0);
			sr2(0)<=cosLine;
		end if;	
	end process;
	


clkOut<= not sr2(0) and sr2(1);

Reg15: Reg
 generic map(Len=>16, Address => Address1)
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toFreqNcoLo
);

Reg16: Reg
 generic map(Len=>16, Address => Address2)
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toFreqNcoHi
);

	nco1: nco 
	port map
	(
		clk =>  clk, --div(4)
		ce	=> one,
		reset => reset ,
		freq => toNCO,
		phase => phase	,															
		sin => open,	
		cos(7) => cosLine,	
		cos(6 downto 0) => open	
		
	);
	
	adder : qadd
	generic map(Q=>22, N=>23)
		port map 
		(
		a(22) => zero,
		a(21 downto 16) => toFreqNcoHi(5 downto 0),
		a(15 downto 0)	=>  toFreqNcoLo(15 downto 0),
	
		b(21 downto 0) => freqControl,
		b(22) => zero,
		c(21) 		=> toNCO(21),
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
		c(0) 		=> toNCO(0),
		c(22)=>open
		);

end rtl;