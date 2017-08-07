library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity true_dpram_sclk is
	port 
	(	
		data_a	: in std_logic_vector(15 downto 0);
		data_b	: in std_logic_vector(15 downto 0);
		addr_a	: in std_logic_vector(8 downto 0); ------8 9
		addr_b	: in std_logic_vector(8 downto 0);
		we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		clka		: in std_logic;
		clkb		: in std_logic;
		q_a		: out std_logic_vector(15 downto 0);
		q_b		: out std_logic_vector(15 downto 0)
	);
	
end true_dpram_sclk;

architecture rtl of true_dpram_sclk is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(511 downto 0) of word_t;
	
	-- Declare the RAM
	shared variable ram : memory_t;

begin

	-- Port A
	process(clka)
	begin
		if(rising_edge(clka)) then 
			if(we_a = '1') then
				ram(conv_integer(addr_a)) := data_a;
			end if;
			q_a <= ram(conv_integer(addr_a));
		end if;
	end process;
	
	-- Port B
	process(clkb)
	begin
		if(rising_edge(clkb)) then
			if(we_b = '1') then
				ram(conv_integer(addr_b)) := data_b;
			end if;
			q_b <= ram(conv_integer(addr_b));
		end if;
	end process;
end rtl;