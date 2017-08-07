library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY adc IS
-- Declarations
port (	clk100 : in std_logic;
			dataIn : in std_logic_vector(7 downto 0);
			clkOut : out std_logic;
			data :out std_logic_vector(7 downto 0)
);
END adc ;

-- hds interface_end
ARCHITECTURE behavior OF adc IS
signal adcdiv: std_logic_vector(27 downto 0):=x"0000000";
begin

process(clk100)
begin
	if rising_edge(clk100) then
		adcdiv <= adcdiv+1;
		if (adcdiv = x"186A") then
				clkOut<='1';
		end if;
		
		if (adcdiv = x"30D4") then   --100M/12500 = 8000
			adcdiv <= x"0000000";
			data <= dataIn;
			clkOut<='0';
		end if;
		
	end if;
end process;
END behavior;


