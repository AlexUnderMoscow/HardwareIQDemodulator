library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity DeltaPulse is
port(
	clk : in std_logic;
	O: out std_logic_vector(15 downto 0)
);
end DeltaPulse;

architecture Behavioral of DeltaPulse is
	signal cnt : std_logic_vector(7 downto 0):=x"00";
	
begin
	O(15 downto 9) <= "0000000";
	O(7 downto 0) <= "00000000" ;
	process(clk)
	
	begin 

		if rising_edge(clk) then
			cnt <= cnt + 1;
			if (cnt=x"00") then
				O(8)<='1';
			else
				O(8)<='0';
			end if;
		end if;
	end process;
	end Behavioral;