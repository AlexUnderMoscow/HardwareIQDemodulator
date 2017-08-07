library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity NetSend is
    Port (       
						clkData		:	in std_logic;
						clk100		:	in std_logic;
						dataI			: 	in std_logic_vector(15 downto 0);
						dataQ			: 	in std_logic_vector(15 downto 0);
						E_TX_EN  	: 	out std_logic;                       -- Sender Enable.
						E_TXD    	: 	out std_logic_vector(3 downto 0);    -- Sent Data.
						E_TX_CLK 	: in  std_logic;                       -- Sender Clock.
						X1 			: 	out std_logic
			  );
end NetSend;

architecture rtl of NetSend is

component mac_snd is
		port(
			phen 					: out std_logic;	
			E_TX_CLK 			: in  std_logic;                       -- Sender Clock.
			E_TX_EN  			: out std_logic;                       -- Sender Enable.
			E_TXD   				 : out std_logic_vector(3 downto 0);    -- Sent Data.
			dataI  			: in  std_logic_vector(15 downto 0);    --
			dataQ  			: in  std_logic_vector(15 downto 0);    --
			addr 				:out std_logic_vector(7 downto 0); 				--8
			--LED  					: out  std_logic_vector(3 downto 0);    -- 
			clkRead 				:out std_logic;		
			en       			: in  std_logic                        -- User Start Send. 
		);
	end component;

component Buf is
 generic (Len: integer := 16);
port(
	clk : in std_logic;
	Data: in std_logic_vector(Len-1 downto 0);
	outData : out std_logic_vector(Len-1 downto 0)
);
end component;
	
component block1 is
port(
	I0,I1,I2,I3,I4,I5,I6,I7 : in std_logic; --I8
	reset: in std_logic;
	startNoise : out std_logic;
	O: out std_logic
);
end component;	



component bin2tcv
port(
	x: in std_logic_vector(15 downto 0);
	y: out std_logic_vector(15 downto 0)
);
end component;

component true_dpram_sclk
        port(
             data_a	: in std_logic_vector(15 downto 0);
					data_b	: in std_logic_vector(15 downto 0);
					addr_a	: in std_logic_vector(8 downto 0); --8 9
					addr_b	: in std_logic_vector(8 downto 0);
					we_a	: in std_logic := '1';
					we_b	: in std_logic := '0';
					clka		: in std_logic;
					clkb		: in std_logic;
					q_a		: out std_logic_vector(15 downto 0);
					q_b		: out std_logic_vector(15 downto 0)
        );
end component;

	signal zero : std_logic_VECTOR(15 downto 0):=x"0000";
	signal one : std_logic:='1';
	signal div: std_logic_vector(1 downto 0);
	signal cnt: std_logic_vector(8 downto 0):="000000000";  --9 8
	signal addrMem : std_logic_vector(7 downto 0);  --8
	signal reset : std_logic;
	signal start: std_logic;
	signal toclkb: std_logic;
	signal dataNet1 : std_logic_vector (15 downto 0);
	signal dataNet2 : std_logic_vector (15 downto 0);
	signal invOut : std_logic;
	signal samplesI: std_logic_vector(15 downto 0);
	signal samplesQ: std_logic_vector(15 downto 0);
	
	signal fromBufCos: std_logic_vector(15 downto 0);
	signal fromBufSin: std_logic_vector(15 downto 0);
	signal falingCLK : std_logic;

begin

falingCLK <= not E_TX_CLK;
X1 <= div(1);
invOut <= not cnt(8);  ----------------------------------9 8


	process(clkData) --div(4)
	begin	
		if (rising_edge(clkData)) then
			cnt<=cnt+1;
		end if;	
	end process;
	
	blk1: block1 
	port map(
			I0=>cnt(0),
			I1=>cnt(1),
			I2=>cnt(2),
			I3=>cnt(3),
			I4=>cnt(4),
			I5=>cnt(5),
			I6=>cnt(6),
			I7=>cnt(7),
			--I8=>cnt(8), ---------------------------------
			reset=> reset,
			startNoise => open,
			O => start
	);
	
	mem1: true_dpram_sclk 
	port map(
					data_a => samplesI,				
					data_b(15 downto 0) => zero,
					addr_a => cnt,
					addr_b(8)=> invOut,												------9
					addr_b(7 downto 0) => addrMem,									--8						
					we_a => one,
					we_b => zero(0),
					clka => clkData,  
					clkb => falingCLK,--E_TX_CLK,--toclkb,
					q_a => open,
					q_b => dataNet1		
	);
	

	
	mem2: true_dpram_sclk 
	port map(
					data_a => samplesQ,				
					data_b(15 downto 0) => zero,
					addr_a => cnt,
					addr_b(8)=> invOut,											--
					addr_b(7 downto 0) => addrMem,								--
					we_a => one,
					we_b => zero(0),
					clka => clkData,  
					clkb => falingCLK,--E_TX_CLK,--toclkb,
					q_a => open,
					q_b => dataNet2		
	);

	mac_send : mac_snd 
	port map(	
			E_TX_CLK => E_TX_CLK,
			E_TX_EN  => E_TX_EN,
			E_TXD   => E_TXD,
			addr => addrMem,	
			phen	 => reset,
			dataI  => dataNet1,
			dataQ  => dataNet2,
			clkRead => toclkb,
			en => start
			--LED  => LED   
   );
	
bufCos: Buf 
 generic map(Len=>16)
port map(
	clk =>clkData,
	Data=>dataI,
	outData =>fromBufCos
);

bufSin: Buf 
 generic map(Len=>16)
port map(
	clk =>clkData,
	Data=>dataQ,
	outData =>fromBufSin
);

	
conv1: bin2tcv
port map
(
	x=>fromBufCos,-- dataI,--fromBufCos,
	y=>samplesI
);

conv2: bin2tcv
port map
(
	x=>fromBufSin,-- dataQ,--fromBufSin,
	y=>samplesQ
);

	
end rtl;