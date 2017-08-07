library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FAPCH is
	generic (Address1: std_logic_vector(7 downto 0);
					Address2: std_logic_vector(7 downto 0)
	);
    Port (       
						clk					:	in std_logic;
						alfa					:	in std_logic;						
						reset					: 	in std_logic;
						fromDetector		: 	in std_logic_vector(15 downto 0);
						omega					: 	out std_logic_vector(15 downto 0);
						clkData				:	in std_logic;						
						data					: 	in std_logic_vector(15 downto 0);
						addr					: 	in std_logic_vector(7 downto 0)
			);					

end FAPCH;

architecture rtl of FAPCH is

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

component STD_FIFO
	Generic (
		 DATA_WIDTH  : integer;
		 FIFO_DEPTH	: integer
	);
	Port ( 
		CLK		: in  STD_LOGIC;
		RST		: in  STD_LOGIC;
		DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
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

component tcv2bin
generic (WIDT: integer);
port(
	x		: in std_logic_vector(15 downto 0);
	y		: out std_logic_vector(15 downto 0)
);
end component;

component bin2tcv
generic (WIDT: integer);
port(
	x		: in std_logic_vector(15 downto 0);
	y		: out std_logic_vector(15 downto 0)
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

signal toPh:	std_logic_vector(15 downto 0);
signal toW:	std_logic_vector(15 downto 0);
signal fromSum:	std_logic_vector(15 downto 0);
signal uvh:	std_logic_vector(15 downto 0);
signal result:	std_logic_vector(15 downto 0);
signal result2:	std_logic_vector(15 downto 0);
signal toOut:	std_logic_vector(15 downto 0);
signal acc:	std_logic_vector(15 downto 0):=x"0000";

signal toXor : std_logic;
signal fromXor : std_logic_vector(15 downto 0);

signal toConv1 : std_logic_vector(15 downto 0);
signal fromConv1 : std_logic_vector(15 downto 0);

signal toConv2 : std_logic_vector(15 downto 0);
signal fromConv2 : std_logic_vector(15 downto 0);
signal fromfifo : std_logic_vector(15 downto 0);


begin


toXor<=fromfifo(15);
fromXor(15) <= toXor xor alfa;
fromXor(14 downto 0) <= fromfifo(14 downto 0);

	clk_process: process(clk)
	begin	
		if rising_edge(clk) then

			acc <= acc + fromConv1;		--аккумулятор -
		end if;	
	end process;
---------------------------------
	fifo : STD_FIFO
	generic map(
		 DATA_WIDTH  => 16,
		 FIFO_DEPTH	=> 16
	)
	port map( 
		CLK		=> clk,
		RST		=> reset,
		DataIn	=> fromDetector,
		DataOut	=> fromfifo
	);
-----------------------------------	
	multW : qmult
	generic map(Q=>9, N=>16)
		port map 
		(
			mul1 => fromXor,		
			mul2 => toW, 			
			o_result 	=> toConv1,
			ovr => open
		);
	-----------------------------------	
	multPh : qmult
	generic map(Q=>9, N=>16)
		port map 
		(
			mul1 => fromXor,		
			mul2 => toPh, 			
			o_result 	=> result2,
			ovr => open
		);	
		
conv1: bin2tcv
generic map(WIDT => 16)
port map
(
	x=>toConv1,
	y=>fromConv1
);

conv2: tcv2bin
generic map(WIDT => 16)
port map
(
	x=>acc,
	y=>fromConv2
);
		
	add : qadd
	generic map(Q=>9, N=>16)
		port map (
			a 		=> fromConv2,
			b 		=> result2,
			c 		=> omega
			);  
			
Reg4: Reg
 generic map(Len=>16, Address => Address1)
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toW
);

Reg5: Reg
 generic map(Len=>16, Address => Address2)
port map(
	clk => clkData,
	rst => reset ,
	Addr => addr,
	Data => data,
	outData => toPh
);

end rtl;