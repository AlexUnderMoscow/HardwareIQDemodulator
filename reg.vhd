library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Reg is
 generic (Len: integer := 16; Address : std_logic_vector(7 downto 0) :="00000001");
port(
	clk : in std_logic;
	rst : in std_logic;
	Addr: in std_logic_vector(7 downto 0);
	Data: in std_logic_vector(Len-1 downto 0);
	outData : out std_logic_vector(Len-1 downto 0)
);
end Reg;

architecture rtl of Reg is
begin
	proc: process (rst,clk)
	begin
		if (rst='1') then
			outData<=x"0000";
		elsif rising_edge(clk) then
			if (Addr=Address) then
				outData<=Data;
			end if;
		end if;
	end process;
	
end rtl; --rtl