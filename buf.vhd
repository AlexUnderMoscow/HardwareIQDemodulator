library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Buf is
 generic (Len: integer := 16);
port(
	clk : in std_logic;
	Data: in std_logic_vector(Len-1 downto 0);
	outData : out std_logic_vector(Len-1 downto 0)
);
end Buf;

architecture rtl of Buf is
begin
	proc: process (clk)
	begin
		if rising_edge(clk) then
				outData<=Data;
		end if;
	end process;
	
end rtl; --rtl