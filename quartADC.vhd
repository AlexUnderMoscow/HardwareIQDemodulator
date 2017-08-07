library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

library work;


entity quartADC is
   port(
      CLK25 : in  std_logic;                       
      E_TX_CLK : in  std_logic;                       -- Sender Clock.
      E_TX_EN  : out std_logic;                       -- Sender Enable.
      E_TXD    : out std_logic_vector(3 downto 0);    -- Sent Data.
		X1 : out std_logic;
		clk: in std_logic;
		phy_rst_n: out std_logic;
		mdc : out std_logic;
		mdio : inout std_logic;
		--
		RX_CLK 	: in  std_logic;                      -- Receiver Clock.
      RX_DV  	: in  std_logic;                      -- Received Data Valid.
		E_RXD    	: in  std_logic_vector(3 downto 0);   -- Received Nibble.
		LED  		: out  std_logic_vector(3 downto 0);    	--
		--
		c1:out std_LOGIC;
		c2:out std_LOGIC;
		c3:out std_LOGIC;
		c4:out std_LOGIC;
		--
		clk25out : in std_logic;
		GTX_CLK : out std_logic
   );
end quartADC;

architecture rtl of quartADC is

	
component MDIO_main is
port(
				clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  enable	: in std_logic;
           mdc : out  STD_LOGIC;
			  NcoEn : out std_logic;
           mdiodata : inout  STD_LOGIC
		);
end component;	

component NetSend is
    Port (       
						clkData		:	in std_logic;
						clk100		:	in std_logic;
						dataI			: 	in std_logic_vector(15 downto 0);
						dataQ			: 	in std_logic_vector(15 downto 0);
						E_TX_EN  	: 	out std_logic;                       -- Sender Enable.
						E_TXD    	: 	out std_logic_vector(3 downto 0);    -- Sent Data.
						E_TX_CLK : in  std_logic;                       -- Sender Clock.
						X1 			: 	out std_logic
			  );
end component;

component GeneralReset is
		    Port ( Reset : out  STD_LOGIC;
			 			enable	: out std_logic;
           clk : in  STD_LOGIC);
end component;


-----------------------------------------------------------------------------------

component pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC;
		c2    : OUT STD_LOGIC	
	);
END component;
 


component DeltaPulse is
port(
	clk : in std_logic;
	O: out std_logic_vector(15 downto 0)
);
end component;	

component MUX IS
port (	
			control: in std_logic_vector(1 downto 0);
			In1	: in std_logic_vector(15 downto 0);
			In2	: in std_logic_vector(15 downto 0);
			In3	: in std_logic_vector(15 downto 0);
			In4	: in std_logic_vector(15 downto 0);
			Out1	: out std_logic_vector(15 downto 0)

);
END component ;




component gng is
port(
	   -- System signals
     clk: in std_logic; 							--,                    // system clock
    rstn : in std_logic; 				--		,                   // system synchronous reset, active low

    -- Data interface
    ce : in std_logic; 							--,                     // clock enable
    valid_out: out std_logic;							--,             // output data valid
    data_out: out std_logic_vector(15 downto 0)			--        // output data, s<16,11>
);
end component;



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
	x		: in std_logic_vector(WIDT-1 downto 0);
	y		: out std_logic_vector(WIDT-1 downto 0)
);
end component;

component bin2tcv
generic (WIDT: integer);
port(
	x		: in std_logic_vector(WIDT-1 downto 0);
	y		: out std_logic_vector(WIDT-1 downto 0)
);
end component;

component Pila 
port(
	clk : in std_logic;
	outData : out std_logic_vector(15 downto 0)
);
end component;
 

component mac_rcv is
port(
		E_RX_CLK 	: in  std_logic;                      -- Receiver Clock.
      E_RX_DV  	: in  std_logic;                      -- Received Data Valid.
      E_RXD    	: in  std_logic_vector(3 downto 0);   -- Received Nibble.
      el_byte  	: out std_logic_vector(7 downto 0);   -- 
      el_addr  	: out std_logic_vector(15 downto 0);  -- 
		samples		: out std_logic_vector(15 downto 0);
		samplesCLK	: out std_logic;
		clkEnable	: out std_logic;
      el_dv    	: out std_logic                      -- EtherLab data valid.
);
end component;

component PSKimit is
    Port (       
						clk			:	in std_logic;						
						RegData  	: 	in std_logic_vector(15 downto 0);
						reset			: 	in std_logic;
						RegAddr		: 	in std_logic_vector(7 downto 0);
						PSK	 		: out std_logic_vector(15 downto 0);
						writeReg		:	in std_logic						
			);					
end component;

component PSKDem is
    Port (       
						clk			:	in std_logic;
						y				: 	in std_logic_vector(15 downto 0);						
						RegAddr  	: 	in std_logic_vector(7 downto 0);
						reset			: 	in std_logic;
						RegData		: 	in std_logic_vector(15 downto 0);
						I	 			: out std_logic_vector(15 downto 0);
						clkDetectI	: out std_logic_vector(15 downto 0);
						symbolCLK	: out std_logic_vector(15 downto 0);
						Q	 			: out std_logic_vector(15 downto 0);
						writeReg		:	in std_logic						
			);					
end component;
 
 -----------------------------------------------------------------------------------------------------
	
	
signal one : std_logic:='1';
	signal zero : std_logic_VECTOR(15 downto 0):=x"0000";
	signal div: std_logic_vector(18 downto 0);
	-----------------------------------------------
	signal dataReg : std_logic_vector(7 downto 0);
	signal addrROM : std_logic_vector(7 downto 0);
	signal clkROM : std_logic;
	-----------------------------------------------
	signal fromCosFir : std_logic_vector(15 downto 0);
	signal fromSinFir : std_logic_vector (15 downto 0);
	
	signal zeroMult: std_logic_VECTOR(7 downto 0):="00000000";
	
	--signal noiseData: std_logic_vector(15 downto 0);
	signal coefWire: std_logic_vector(15 downto 0);
	signal hclock : std_logic;
	signal RegData: std_logic_vector(15 downto 0);
	--signal mulCos : std_logic_vector (15 downto 0);
	signal Reg1Data : std_logic_vector (15 downto 0);
	signal inputSamples : std_logic_vector(15 downto 0);
	signal toMux1 : std_logic_vector(15 downto 0);
	signal toMux2 : std_logic_vector(15 downto 0);
	signal toMux3 : std_logic_vector(15 downto 0);
	signal toMux4 : std_logic_vector(15 downto 0);
	signal DetectOut : std_logic_vector(15 downto 0);
	signal MuxControl : std_logic_vector(1 downto 0);
	signal coefCLK : std_logic; 			--к тактам загрузки коэффициентов h
	signal addrMatch: std_logic;			--про том что адрес регистра 13
	signal startNoise : std_logic;
	--signal fromConvertor : std_logic_vector(7 downto 0);
	--signal fromConvertor2 : std_logic_vector(7 downto 0);

	signal freq		: std_logic_vector(21 downto 0);
	signal SystemClk : std_logic;
	signal SymbolClock : std_logic;	
	signal mulCoef : std_logic_vector(15 downto 0);	
	signal afterAmp : std_logic_vector(15 downto 0);
	signal alfa			:	 std_logic;
	signal omega		:   std_logic_vector(15 downto 0);
	
	signal fromCosMult : std_logic_vector(15 downto 0); --from cos*sin
	signal toDetector : std_logic_vector(15 downto 0); --to cos*sin
	
	signal freqCLK : std_logic_vector(21 downto 0):="0000000000000000000000";
	signal toNetwork : std_logic_vector(15 downto 0);
	signal toCosDetector : std_logic_vector(15 downto 0);
	
	signal fromInput : std_logic_vector(15 downto 0);
	signal Gun1Cos : std_logic_vector(15 downto 0);
	signal Gun1Sin : std_logic_vector(15 downto 0);
	signal fromPila : std_logic_vector(15 downto 0);
	
signal mdio_oen: std_logic;
signal mdio_out: std_logic;
signal mdio_in: std_logic;

signal mdcTest: std_LOGIC;
signal mdioTest : std_LOGIC;

--signal clk25: std_logic;
signal clk50: std_logic;
signal clk125: std_logic;
signal clk250: std_logic;

signal enable : std_logic;

signal toMacEn: std_logic;
signal GReset: std_logic;
signal clock25MHZ: std_logic;
signal clock250MHZ: std_logic;
signal buf: std_logic;

signal clkDetectI : std_logic_vector(15 downto 0);
signal symbolCLK	:  std_logic_vector(15 downto 0);
--signal LED: std_logic_vector(3 downto 0);
	
begin



GTX_CLK <= CLK125;
--E_TXD(7 downto 4) <= "0000";
--E_RXD(7 downto 4) <= "0000";
mdc <= mdcTest;
mdio <= mdioTest;
clock25MHZ <= E_TX_CLK;
phy_rst_n <= not Greset;


Gun1Sin(14 downto 7) <= x"00";

--LED <= dataNet(11 downto 8);
LED <= not Reg1Data(3 downto 0);


toNetwork <= toDetector;
toCosDetector(14 downto 7)<=x"00";

freq(21) <= omega(15);
freq(20 downto 17) <= "0000";
freq(1 downto 0) <= "00";
freq(16 downto 2) <= omega(14 downto 0);
toMux1(14 downto 7) <= x"00";

X1 <= Reg1Data(15);

--toMux2 <= noiseData;
toMux3 <= RegData;
MuxControl <= Reg1Data(13 downto 12);
toDetector(14 downto 7) <= x"00";

SystemClk <= div(8) and Reg1Data(15); 		--1111!!!!!!!!!!!!!!!!!!

c1<= enable;
--c2<= GReset;
c3<= mdcTest;
c4<= mdioTest;

buf <= E_TX_CLK;

process(clk)
	begin	
		if clk'event and clk = '1' then
			div<=div+1;
		end if;	
	end process;

	

	
imit: PSKimit 
    Port map(       
						clk			=>SystemClk,			
						RegData  	=>RegData,
						reset			=>zero(0),
						RegAddr		=>dataReg,
						PSK	 		=> Gun1Cos,
						writeReg		=>clkROM							
			);
		
pila1: Pila 
port map(
	clk => SystemClk,
	outData => fromPila
);
		
Reg1: Reg
 generic map(Len=>16, Address => x"01")
port map(
	clk => clkROM,
	rst => zero(0) ,
	Addr => dataReg,
	Data => RegData,
	outData => Reg1Data
);

				  
	NETRCV: mac_rcv
	port map(
			E_RX_CLK => RX_CLK,
			E_RX_DV  => RX_DV,                      -- Received Data Valid.
			E_RXD  =>  E_RXD,   								-- Received Nibble.
			el_byte => dataReg,  							--  			-- 
			el_addr(15 downto 0) => RegData,
			samples		=> fromInput,
			samplesCLK	=> open, --systemClk,	--open, --!!!!!!!!!!!!!!systemClk,
			clkEnable => hclock , 								--zero(7),							--блокировка clk
			el_dv   => clkROM                   		-- EtherLab data valid.
		);

	input : tcv2bin
	generic map(WIDT => 16)
	port map(
		x => fromInput,				
		y => inputSamples
	);

	NET:NetSend 
    port map (       
						clkData => SystemClk,
						clk100 => clk125,
						dataI =>  clkDetectI,		--	fromPila,--Gun1Cos,--,--fromCosFir,--omega, --Gun1Cos, --fromPila,--, --omega
						dataQ=> 	 symbolCLK, --fromCosFir, --, --fromSinFir, --DetectOut,--, --,-- afterAmp, --fromSinFir,--inputSamples,-- fromPila, --mulCoef, --toCosDetector,  
						E_TX_EN => E_TX_EN,
						E_TXD => E_TXD,
						E_TX_CLK => E_TX_CLK,-- clk50,--clock250MHZ,--clk250, --E_TX_CLK,
						X1 => open 
			  );

dem: PSKDem 
    Port map(       
						clk			=> SystemClk,		--:	in std_logic;
						y				=> Gun1Cos, 		--: 	in std_logic_vector(15 downto 0);						
						RegAddr  	=>dataReg,			--: 	in std_logic_vector(7 downto 0);
						reset			=> zero(0),			--: 	in std_logic;
						RegData		=>RegData,			--: 	in std_logic_vector(15 downto 0);
						I	 			=>fromCosFir,		--: out std_logic_vector(15 downto 0);
						clkDetectI 	=> clkDetectI,
						symbolCLK	=> symbolCLK,
						Q	 			=>fromSinFir,		--: out std_logic_vector(15 downto 0);
						writeReg		=>clkROM				--:	in std_logic						
			);				  
			  
pll_inst: pll
port map(
	inclk0=>CLK25,
	c0=>clk50,
	c1=>clk125,
	c2=>clk250
);

--pll_inst1: pll
--port map(
--	inclk0=>buf,
--	c0=>clock250MHZ
	--c1=>clk125,
	--c2=>clk250
--);

	mdio1: MDIO_main PORT MAP(
				clk => div(12),  --18 14 12 10
           reset=> GReset,
			  enable => enable,
           mdc => mdcTest,
			  NcoEn => toMacEn,
           mdiodata => mdioTest 		  
	);

	GR: GeneralReset PORT MAP(
		clk => div(8),
		enable => enable,
		Reset => Greset
	);
	

   
end rtl;