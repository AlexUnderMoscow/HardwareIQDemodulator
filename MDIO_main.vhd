
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MDIO_main is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  enable	: in std_logic;
           mdc : out  STD_LOGIC;
			  NcoEn : out std_logic;
           mdiodata : inout  STD_LOGIC);
end MDIO_main;

architecture Behavioral of MDIO_main is

component mdio_control is
port(
		clk	: in	std_logic;
		reset	 : in	std_logic;
		datain : in std_logic_vector(15 downto 0);
		enable	: in std_logic;
		convertion : out std_logic;
		dataout : out std_logic_vector(15 downto 0);
		opcode : out std_logic_vector(1 downto 0);
		NcoEn : out std_logic;
		RegNum : out std_logic_vector(4 downto 0)	
);
end component;


component mdio is
port(
   reset					: in std_logic;
	clk_in 				: in std_logic; -- deve essere < 2.5 MHz!
	serial_clock    	: out std_logic := '0'; -- deve essere < 2.5 MHz!
	serial_data     	: inout std_logic;
	device_address    : in std_logic_vector (4 downto 0);

	-- 00: Address
        -- 10: Read-Inc
	-- 11: Read
        -- 01: Write
	opcode  					: in std_logic_vector(1 downto 0);
	data_read      		 : out std_logic_vector(15 downto 0);
	data_write     		 : in std_logic_vector(15 downto 0);
	start_conversion		: in std_logic;
	running_conversion  	: out std_logic;
	error_code          	: out std_logic_vector(2 downto 0)

);
end component;

	signal convertion: std_logic;
	signal dataToMdio: std_logic_vector(15 downto 0);
	signal dataFromMdio: std_logic_vector(15 downto 0);
	signal device_address : std_logic_vector(4 downto 0);
	signal opcode : std_logic_vector(1 downto 0);

begin

	mdio1 : mdio port map(	
				reset => reset,
				clk_in	=>	clk,	
				serial_clock => mdc,
				serial_data	=> mdiodata,
				device_address => device_address,
				opcode => opcode,
				data_read => dataFromMdio,
				data_write => dataToMdio,
				start_conversion => convertion,
				running_conversion => open,
				error_code => open
				
   );
	
	mdio_control1 : mdio_control port map(	
		clk => clk,	
		reset	 => reset,
		datain => dataFromMdio,
		enable => enable,
		convertion => convertion,
		dataout => dataToMdio,
		NcoEn => NcoEn,
		opcode => opcode,
		RegNum => device_address
   );

end Behavioral;

