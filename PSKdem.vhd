library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity PSKDem is
    Port (       
						clk			:	in std_logic;
						y				: 	in std_logic_vector(15 downto 0);						
						RegAddr  	: 	in std_logic_vector(7 downto 0);
						reset			: 	in std_logic;
						RegData		: 	in std_logic_vector(15 downto 0);
						clkDetectI	: out std_logic_vector(15 downto 0);
						symbolCLK	: out std_logic_vector(15 downto 0);
						I	 			: out std_logic_vector(15 downto 0);
						Q	 			: out std_logic_vector(15 downto 0);
						writeReg		:	in std_logic						
			);					
end PSKDem;

architecture rtl of PSKDem is

component FAPCH is
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
end component;

component clkFAPCH is
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
end component;

component CLKdetect is
    Port (       
						clk				:	in std_logic;	
						clkFix			:	in std_logic;						
						detectOutI  	: 	out std_logic_vector(15 downto 0);
						detectOutQ  	: 	out std_logic_vector(15 downto 0);
						reset				: 	in std_logic;					
						dataI				: 	in std_logic_vector(15 downto 0);
						dataQ				: 	in std_logic_vector(15 downto 0)
			);					

end component;

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

component ARU is
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

component fir is
port(
			dataCos : in  STD_LOGIC_VECTOR (15 downto 0);
			dataSin : in  STD_LOGIC_VECTOR (15 downto 0);
          clk : in  STD_LOGIC;
          hIn : in  STD_LOGIC_VECTOR (15 downto 0);
          hclk : in  STD_LOGIC;
			 alpha : out std_logic;
			 betta : out std_logic;
          cosOut : out  STD_LOGIC_VECTOR (15 downto 0);
			 sinOut : out  STD_LOGIC_VECTOR (15 downto 0)
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

component qmult
	generic(Q : integer; N : integer);
	port (
   mul1 : in std_logic_vector (N-1 downto 0);
	mul2 : in std_logic_vector (N-1 downto 0);
	o_result : out std_logic_vector (N-1 downto 0);
	ovr : out std_logic
);
end component;

signal one : std_logic:='1';
	signal zero : std_logic_VECTOR(15 downto 0):=x"0000";
	signal div: std_logic_vector(18 downto 0);
	-----------------------------------------------
	--signal dataReg : std_logic_vector(7 downto 0);
	--signal addrROM : std_logic_vector(7 downto 0);
	--signal clkROM : std_logic;
	-----------------------------------------------
	signal fromCosFir : std_logic_vector(15 downto 0);
	signal fromSinFir : std_logic_vector (15 downto 0);
	
	signal zeroMult: std_logic_VECTOR(7 downto 0):="00000000";
	
	--signal noiseData: std_logic_vector(15 downto 0);
	signal coefWire: std_logic_vector(15 downto 0);
	signal hclock : std_logic;
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
	signal omegaCLK		:   std_logic_vector(15 downto 0);
	
	signal fromCosMult : std_logic_vector(15 downto 0); --from cos*sin
	signal toDetector : std_logic_vector(15 downto 0); --to cos*sin
	
	signal freqCLK : std_logic_vector(21 downto 0);
	signal toNetwork : std_logic_vector(15 downto 0);
	signal toCosDetector : std_logic_vector(15 downto 0);
	
	signal fromInput : std_logic_vector(15 downto 0);
	signal Gun1Cos : std_logic_vector(15 downto 0);
	signal Gun1Sin : std_logic_vector(15 downto 0);
	signal fromPila : std_logic_vector(15 downto 0);
	
	signal clkDet : std_logic_vector(15 downto 0);
	signal fromIfir : std_logic_vector(15 downto 0);



begin
-- далее проверяется адрес 13
addrMatch <= not RegAddr(7) and not RegAddr(6) and not RegAddr(5) and not RegAddr(4) and RegAddr(3) and RegAddr(2) and not RegAddr(1) and RegAddr(0);
coefCLK <= addrMatch and writeReg;

freq(21) <= omega(15);
freq(20 downto 17) <= "0000";
freq(1 downto 0) <= "00";
freq(16 downto 2) <= omega(14 downto 0);

freqCLK(21) <= omegaCLK(15);
freqCLK(20 downto 15) <= "000000";
freqCLK(14 downto 0) <= omegaCLK(14 downto 0);

toMux1(14 downto 7) <= x"00";

--symbolCLK(15 downto 8) <= "00000000";
--symbolCLK(6 downto 0) <= "0000000";
--symbolCLK(7) <= SymbolClock;
symbolCLK <= clkDet;
--clkDetectI <= clkDet; 	--!!!--
clkDetectI <= omegaCLK; 	--!!!--

I <= fromIfir;

fap : FAPCH
 generic map(Address1 => x"04",Address2 => x"05")
    port map(       
						clk					=>clk,	--SymbolClock,
						alfa					=>alfa , --fromSinFir(15), --alfa,				
						reset					=>zero(0),
						fromDetector		=> DetectOut,
						omega					=>omega,
						clkData				=>writeReg,				
						data					=>RegData,
						addr					=>RegAddr
			);	
			
	clkfap : clkFAPCH
 generic map(Address1 => x"06",Address2 => x"07")
    port map(       
						clk					=>SymbolClock,	--SymbolClock, clk
						alfa					=>alfa , --fromSinFir(15), --alfa,				
						reset					=>zero(0),
						fromDetector		=> clkDet,
						omega					=>omegaCLK,
						clkData				=>writeReg,				
						data					=>RegData,
						addr					=>RegAddr
			);	

ARU1 : ARU 
    port map(       
						clk			=>SymbolClock,
						alfa			=> fromCosFir(15), --alfa,				
						reset			=>zero(0),
						inPhase		=>fromCosFir, 
						mulCoef		=>mulCoef,
						clkData		=>writeReg,					
						data			=>RegData,
						addr			=>RegAddr
			);	

clock: CLKGen 
generic map(Address1=>x"09", Address2=>x"0A")
    port map(       
						clk								=>clk,					
						clkOut  							=>SymbolClock,
						reset								=>zero(0),
						freqControl(21 downto 0) 	=>freqCLK,				
						clkData							=>writeReg,					
						data								=>RegData,
						addr								=>RegAddr
			);

	mult1 : qmult
	generic map(Q=>9, N=>16)
		port map (
			mul1 => y, 		
			mul2 => mulCoef, 			
			o_result 	=> afterAmp,
			ovr => open);
			
	Detect : qmult
	generic map(Q=>9, N=>16)
		port map (
			mul1 => afterAmp, 
			mul2 => toDetector, --toMux1, --toCosDetector, 			
			o_result 	=> DetectOut,
			ovr => open);

	GUN2: GUN 
	generic map(Len=>16, Address1=>x"0B", Address2=>x"0C") --11 --12
    port map(       
						clk			=> clk,
						reset			=>zero(0) ,
						RegData		=> RegData,
						RegAddr		=> RegAddr,
						writeReg		=> writeReg,
						freqControl => freq,
						sin(6 downto 0)			=> toDetector(6 downto 0),
						sin(7) => toDetector(15),
						cos(6 downto 0) => toCosDetector(6 downto 0),
						cos(7)			=> toCosDetector(15)
			  );	  
			  
	inPhase : qmult
	generic map(Q=>9, N=>16)
		port map (
			mul1 => toCosDetector,		
			mul2 => afterAmp, 			
			o_result 	=> fromCosMult,
			ovr => open);

filter: fir
port map(
			dataCos => fromCosMult, --DetectOut,
			dataSin => DetectOut, --afterAmp, --inputSamples, --Gun1Sin,  --fromCosMult,
          clk => clk,				--div(4)
          hIn => RegData ,
          hclk => coefCLK,
			 alpha => alfa,
			 betta => open,
          cosOut => fromIfir,
			 sinOut => Q
);	

clkDet1: CLKdetect 
    Port map(       
						clk				=>clk,
						clkFix			=> SymbolClock,			
						detectOutI  	=>clkDet,
						detectOutQ  	=>open,
						reset				=>zero(0),				
						dataI				=>fromIfir,
						dataQ				=>zero
			);			

end rtl;