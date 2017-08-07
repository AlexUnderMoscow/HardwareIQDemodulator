library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY MUX IS
-- Declarations
port (	
			control: in std_logic_vector(1 downto 0);
			In1	: in std_logic_vector(15 downto 0);
			In2	: in std_logic_vector(15 downto 0);
			In3	: in std_logic_vector(15 downto 0);
			In4	: in std_logic_vector(15 downto 0);
			Out1	: out std_logic_vector(15 downto 0)

);
END MUX ;

ARCHITECTURE behavior OF MUX IS
begin
	with control select Out1 <=
    In1 when "00",
    In2 when "01",
    In3 when "10",
    In4 when "11";
end behavior;