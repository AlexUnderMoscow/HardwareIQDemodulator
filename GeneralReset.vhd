library IEEE;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_1164.ALL;



entity GeneralReset is
    Port ( 
			Reset : out  STD_LOGIC;
			  enable	: out std_logic;
           clk : in  STD_LOGIC);
end GeneralReset;

architecture Behavioral of GeneralReset is
signal reg: std_logic_vector(7 downto 0):="00000011";
signal cnt: std_logic_vector(3 downto 0):="0000";
begin

Reset<=reg(0);

process (clk)
begin
	if rising_edge(clk) then
		reg(6 downto 0) <= reg (7 downto 1);
		cnt<=cnt+1;
		if (cnt="1010") then
			enable <= '1';
		end if;
	end if;
end process;

end Behavioral;

