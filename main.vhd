library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity main is
 generic (Order: integer := 30; halfOrder : integer :=15; Q : integer:=9; 
				N : integer:=10);--поярдок и полпорядка изменены
port(
	clk : in std_logic;
	dataIn: in std_logic_vector(15 downto 0);--входные данные - 2байтные отсчеты ацп
	clkh: in std_logic;
	hIn: in std_logic_vector(15 downto 0);--коэффициенты фильтра также 2байтные
	outData : out std_logic_vector(15 downto 0);
	outLine : out std_logic 
	--c1 : out std_logic_vector (17 downto 0);
	--c2 : out std_logic_vector (17 downto 0);
	--c : out std_logic_vector (17 downto 0)

);
end main;

architecture rtl of main is


component qmult--умножитель
	generic(Q : integer; N : integer);
	port (
   mul1 : in std_logic_vector (15 downto 0);
	mul2 : in std_logic_vector (15 downto 0);
	o_result : out std_logic_vector (15 downto 0);
	ovr : out std_logic
);
end component;
	
component qadd--сумматор
	generic(Q : integer; N : integer);
	port (
   a : in std_logic_vector (15 downto 0);
	b : in std_logic_vector (15 downto 0);
	c : out std_logic_vector (15 downto 0)
);
end component;
		

	type shiftReg is array(30 downto 0) of std_logic_vector(15 downto 0); --31н 2хбайтный отсчет
	signal sample : shiftReg;
	
	type FirstSums is array(16 downto 1) of std_logic_vector(15 downto 0); --выход первых сумматоров
	signal sumFirst : FirstSums;
	
	type SecondSums is array(7 downto 0) of std_logic_vector(15 downto 0); -- выход вторых сумматоров
	signal sumSecond : SecondSums;
	
	type ThirdSums is array(3 downto 0) of std_logic_vector(15 downto 0); -- выход третьих сумматоров
	signal sumThird : ThirdSums;
	
	type ForthSums is array(1 downto 0) of std_logic_vector(15 downto 0); --выход четвертых сумматоров
	signal sumForth :ForthSums;
	
	type shiftRegH is array(15 downto 0) of std_logic_vector(15 downto 0); --16ть 2хбайтных коэффициентов фильтра
	signal h : shiftRegH;
	
	signal total : std_logic_vector(15 downto 0); --конечная сумма
	signal zero: std_logic:='0';
	
	type MultAr is array(15 downto 0) of std_logic_vector(15 downto 0);--умножители, 16 штук
	signal Mult : MultAr;	
	
begin
	
	clk_process: process(clk) --загрузка отсчетов сигнала
	begin	
		if rising_edge(clk) then
			sample(29 downto 0) <= sample(30 downto 1);
			sample(30) <= dataIn;
		end if;	
		outData <=total;
	end process;
	
	clkh_process: process(clkh) --загрузка коэффициентов фильтра
	begin	
		if rising_edge(clkh) then
			h(14 downto 0) <= h(15 downto 1);
			h(15) <= hIn;
		end if;	
	end process;

GEN_MUL: for I in 0 to halfOrder generate --генерация 16ти умножителей
	
	multX : qmult
	generic map(Q=>Q, N=>N)--N-размерность множителей, Q-размерность дробной части
		port map (
			mul1 => sumFirst(I+1),
			mul2 => h(I),
			o_result 	=> Mult(I),
			ovr => open);
			
end generate GEN_MUL;

--sumFirst(1)(7 downto 0) <=sample(halfOrder)(8 downto 1); 
--sumFirst(1)(8) <=zero; 
sumFirst(1) <=sample(halfOrder); 
			
GEN_SUM: for I in 1 to Order generate --генерация сумматоров

FIRSTSUM: if I < 16 generate
	addfirst : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sample(halfOrder-I),
		--	a(9) 		=> zero,
		--	a(8 downto 0) 		=> sample(halfOrder-I)(8 downto 0),
			
			b 		=> sample(halfOrder+I) ,
		--	b(9) => zero,
		--	b(8 downto 0) 		=> sample(halfOrder+I) (8 downto 0),
			
		--	c(9 downto 1) 		=> sumFirst(I+1)(8 downto 0),
		--	c(0) 		=> open,
			c 		=> sumFirst(I+1));
end generate FIRSTSUM;

SECONDTSUM16: if (I = 16) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-16), --0
			b 		=> Mult(I-15), --1
			c 	=> sumSecond(0));
end generate SECONDTSUM16;

SECONDTSUM17: if (I = 17) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-15), --2 
			b 		=> Mult(I-14), --3 
			c 	=> sumSecond(1));
end generate SECONDTSUM17;

SECONDTSUM18: if (I = 18) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-14), --4 
			b 		=> Mult(I-13), --5 
			c 	=> sumSecond(2));
end generate SECONDTSUM18;

SECONDTSUM19: if (I = 19) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-13), --6
			b 		=> Mult(I-12), --7
			c 	=> sumSecond(3));
end generate SECONDTSUM19;

SECONDTSUM20: if (I = 20) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-12), --8
			b 		=> Mult(I-11), --9
			c 	=> sumSecond(4));
end generate SECONDTSUM20;

SECONDTSUM21: if (I = 21) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-11), --10
			b 		=> Mult(I-10), --11
			c 	=> sumSecond(5));
end generate SECONDTSUM21;

SECONDTSUM22: if (I = 22) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-10), --12
			b 		=> Mult(I-9),  --13
			c 	=> sumSecond(6));
end generate SECONDTSUM22;

SECONDTSUM23: if (I = 23) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> Mult(I-9), --14
			b 		=> Mult(I-8), --15
			c 	=> sumSecond(7));
end generate SECONDTSUM23;

THIRDTSUM1: if (I = 24) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumSecond(0),
			b 		=> sumSecond(1),
			c 	=> sumThird(0));
end generate THIRDTSUM1;

THIRDTSUM2: if (I = 25) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumSecond(2),
			b 		=> sumSecond(3),
			c 	=> sumThird(1));
end generate THIRDTSUM2;

THIRDTSUM3: if (I = 26) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumSecond(4),
			b 		=> sumSecond(5),
			c 	=> sumThird(2));
end generate THIRDTSUM3;

THIRDTSUM4: if (I = 27) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumSecond(6),
			b 		=> sumSecond(7),
			c 	=> sumThird(3));
end generate THIRDTSUM4;

FORTHSUM1: if (I = 28) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumThird(0),
			b 		=> sumThird(1),
			c 	=> sumForth(0));
end generate FORTHSUM1;

FORTHSUM2: if (I = 29) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumThird(2),
			b 		=> sumThird(3),
			c 	=> sumForth(1));
end generate FORTHSUM2;

LASTSUM: if (I = 30) generate
	addsecond : qadd
	generic map(Q=>Q, N=>N)
		port map (
			a 		=> sumForth(0),
			b 		=> sumForth(1),
			c 	=> total);
end generate LASTSUM;
		
 end generate GEN_SUM;
 
end;
	