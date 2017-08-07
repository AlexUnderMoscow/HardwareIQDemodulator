library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Pila is
port(
	clk : in std_logic;
	outData : out std_logic_vector(15 downto 0)
);
end Pila;

architecture rtl of Pila is
signal cnt: std_logic_vector(15 downto 0):=x"0000";
begin

outData <= cnt;

	proc: process (clk)
	begin
		if (rising_edge(clk)) then
			cnt<=cnt+1;	
			if (cnt=x"2710") then
				cnt<=x"0000";
			end if;
		end if;
	end process;
	
end rtl; --rtl