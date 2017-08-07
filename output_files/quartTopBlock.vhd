LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

 
ENTITY mdio_tb IS
END mdio_tb;
 
ARCHITECTURE behavior OF mdio_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mdio
    PORT(
         reset : IN  std_logic;
         clk_in : IN  std_logic;
         serial_clock : out  std_logic;
         serial_data : INOUT  std_logic;
         opcode : IN  std_logic_vector(1 downto 0);
         data_read : OUT  std_logic_vector(15 downto 0);
         data_write : IN  std_logic_vector(15 downto 0);
			device_address    : in std_logic_vector (4 downto 0);
         start_conversion : IN  std_logic;
         running_conversion : OUT  std_logic;
         error_code : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clk_in : std_logic := '0';
   signal opcode : std_logic_vector(1 downto 0) := (others => '0');
   signal data_write : std_logic_vector(15 downto 0) := (others => '0');
   signal start_conversion : std_logic := '0';
	signal device_address : std_logic_vector(4 downto 0);
	--BiDirs
   signal serial_data : std_logic;

 	--Outputs
   signal serial_clock : std_logic;
   signal data_read : std_logic_vector(15 downto 0);
   signal running_conversion : std_logic;
   signal error_code : std_logic_vector(2 downto 0);


   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant serial_clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mdio PORT MAP (
          reset => reset,
          clk_in => clk_in,
          serial_clock => serial_clock,
          serial_data => serial_data,
          opcode => opcode,
			 device_address => device_address,
          data_read => data_read,
          data_write => data_write,
          start_conversion => start_conversion,
          running_conversion => running_conversion,
          error_code => error_code

        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 


   -- Stimulus process
   stim_proc: process
   begin		
      reset<='1';
		start_conversion <= '0';
      wait for 100 ns;	
		reset<='0';
		device_address <="00100";
		start_conversion <= '0';
      wait for clk_in_period*10;
		opcode <= "01";  --Write
		start_conversion <= '1';
		data_write <= x"0103";
		wait for 160 ns;
		start_conversion <= '0';
		
		wait for 5120 ns;	
		
		start_conversion <= '0';

		wait for 5120 ns;	
		wait for 5120 ns;	
		
		opcode <= "10";
		start_conversion <= '1';
		wait for 160 ns;
		start_conversion <= '0';
----		-----------------------------------
		wait for 2100 ns;	
--		serial_data <= '0';
------		--------------------------------
--		wait for 20 ns;
--		serial_data <= '1';
--
--		wait for 20 ns;
--		serial_data <= '1';
--
--		wait for 20 ns;
--		serial_data <= '0';
--
--		wait for 20 ns;
--		serial_data <= '0';
--		
--		wait for 20 ns;
--		serial_data <= '1';
--
--		wait for 20 ns;
--		serial_data <= '0';
--
--		wait for 20 ns;
--		serial_data <= '1';
--		
--		wait for 20 ns;
--		serial_data <= '0';
--		
----8
--
--		wait for 20 ns;
--		serial_data <= '0';
--
--		wait for 20 ns;
--		serial_data <= '0';
--
--		wait for 20 ns;
--		serial_data <= '1';
--
--		wait for 20 ns;
--		serial_data <= '0';
--		
--		wait for 20 ns;
--		serial_data <= '0';
--
--		wait for 20 ns;
--		serial_data <= '1';
--
--		wait for 20 ns;
--		serial_data <= '0';
--		
--		wait for 20 ns;
--		serial_data <= '0';

      wait;
   end process;

END;
