library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity block1 is
port(
	I0,I1,I2,I3,I4,I5,I6,I7 : in std_logic; --,I8
	reset: in std_logic;
	startNoise : out std_logic;
	O: out std_logic
);
end block1;

architecture Behavioral of block1 is
	signal desh, O1,O2 : std_logic:='0';
	
begin
	O<=O2;
	startNoise <= O1;
	desh<=not (I0) and not(I1) and not(I2) and not(I3) and not(I4) and not(I5) and not(I6) and not(I7)  ; --and not (I8)
	process(desh)
	
	begin 
		if (reset='1') then 
			O1 <='1';
			O2 <='0';
		elsif rising_edge(desh) then
			O2<=O1;
			O1<='1';
		end if;
	end process;
	end Behavioral;