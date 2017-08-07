library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity STD_FIFO is
	Generic (
		 DATA_WIDTH  : integer := 16;
		 FIFO_DEPTH	: integer := 16
	);
	Port ( 
		CLK		: in  STD_LOGIC;
		RST		: in  STD_LOGIC;
		DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
	);
end STD_FIFO;
 
architecture Behavioral of STD_FIFO is
	type shiftReg is array(FIFO_DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal sample : shiftReg;
begin
 
	-- Memory Pointer Process
	fifo_proc : process (CLK)
		

	begin
		if rising_edge(CLK) then
			if RST = '1' then

			else
				sample(FIFO_DEPTH-1) <=  DataIn;
				sample(FIFO_DEPTH-2 downto 0) <= sample(FIFO_DEPTH-1 downto 1);
				DataOut <= sample(0);
			end if;
			
		end if;
	end process;
		
end Behavioral;