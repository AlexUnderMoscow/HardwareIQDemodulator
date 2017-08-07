library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity ARU is
    Port (       
						clk			:	in std_logic;
						alfa			:	in std_logic;						
						reset			: 	in std_logic;
						inPhase		: 	in std_logic_vector(15 downto 0);
						mulCoef		: 	out std_logic_vector(15 downto 0);
						clkData		:	in std_logic;						
						data			: 	in std_logic_vector(15 downto 0);
						addr			: 	in std_logic_vector(7 downto 0)
			);					

end ARU;

architecture rtl of ARU is

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

component qadd
	generic(Q : integer; N : integer);
	port (
   a : in std_logic_vector (15 downto 0);
	b : in std_logic_vector (15 downto 0);
	c : out std_logic_vector (15 downto 0)
);
end component;


component qmult
	generic(Q : integer; N : integer);
	port (
   mul1 : in std_logic_vector (15 downto 0);
	mul2 : in std_logic_vector (15 downto 0);
	o_result : out std_logic_vector (15 downto 0);
	ovr : out std_logic
);
end component;

signal toSum:	std_logic_vector(15 downto 0);
signal toMul:	std_logic_vector(15 downto 0);
signal fromSum:	std_logic_vector(15 downto 0);
signal fromSum1:	std_logic_vector(15 downto 0);
signal uvh:	std_logic_vector(15 downto 0);
signal result:	std_logic_vector(15 downto 0);


signal addrMatch: std_logic;			--адрес регистра 18
signal acc:	std_logic_vector(15 downto 0):=x"0000"; --0000
signal toXor : std_logic;
signal fromXor : std_logic;
signal one: std_logic:='1';



begin


addrMatch <= not addr(7) and not addr(6) and not addr(5) and  addr(4) and not addr(3) and not addr(2) and  addr(1) and not addr(0); --"00010010" = 18 = 0x12
mulCoef<=acc;
toXor<=inPhase(15);
fromXor <= toXor xor alfa;

	clk_process: process(clk,clkData,reset)
	begin	
		if (reset='1') then
			acc <= x"0000";
			uvh <= x"0000";
		elsif ((clkData = '1') and (addrMatch='1')) then
				acc <= data;
				uvh <= x"0000";
		elsif rising_edge(clk) then
			uvh(14 downto 0) <= inPhase(14 downto 0);
			uvh(15) <= fromXor;
			acc <= fromSum1;
		end if;	
		
	end process;
	


	addAcc : qadd
	generic map(Q=>9, N=>16)
		port map (
			a							=> result,
			b							=>	acc,		
			c 							=> fromSum1
			);  
	
	mult : qmult
	generic map(Q=>9, N=>16)
		port map 
		(
			mul1 => fromSum,		
			mul2 => toMul, 			
			o_result 	=> result,
			ovr => open
		);
		

		
	add : qadd
	generic map(Q=>9, N=>16)
		port map (
			a 		=> uvh,
			b 		=> toSum,
			c 		=> fromSum
			);  
			
Reg19: Reg
 generic map(Len=>16, Address => x"13")
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toSum
);

Reg20: Reg
 generic map(Len=>16, Address => x"14")
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toMul
);

end rtl;