library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity block2 is
port(
	I : in std_logic;
	O: out std_logic
);
end block2;

architecture Behavioral of block2 is
	signal O1,O2 : std_logic:='0';
	
begin
	O<=O2;

	process(I)
	
	begin 
		if rising_edge(I) then
			O2<=O1;
			O1<='1';
		end if;
	end process;
	end Behavioral;