library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity BusClkGen is
port(
	clk	: in std_logic;
	clkOut : out std_logic;
	Addr: in std_logic_vector(7 downto 0)
);
end BusClkGen;

architecture rtl of BusClkGen is
signal old: std_logic_vector(7 downto 0):=x"00";
begin
	proc: process (clk)
	begin
	if (rising_edge(clk)) then
		if (Addr /=old) then
			clkOut <='1';
		else
			clkOut <='0';
		end if;
		old <= Addr;
	end if;
	end process;
	
end rtl; --rtl