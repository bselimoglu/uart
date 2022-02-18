LIBRARY IEEE ;
LIBRARY WORK ;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.WAVE_GEN_PKG.ALL;

entity uart_top is 
generic(
osc_freq              : integer range 0 to 100000000 := 100_000_000;
width                 : integer range 0 to 8 := 8;
no_of_sample          : integer range 0 to 16 := 16
);
port(	
--------------- INPUTS --------------------------------------------

clk                   :in std_logic;
sw                    :in std_logic_vector(2 downto 0);	
rx_din                :in std_logic;
tx_data               :in std_logic_vector(7 downto 0);
tx_send               :in std_logic;

--------------- OUTPUTS --------------------------------------------		

tx_dout               :out std_logic;	
tx_active             :out std_logic;
rx_data_ready         :out std_logic;
rx_data               :out std_logic_vector(7 downto 0)
);
end uart_top;

architecture struct of uart_top is
	
signal baud_en_rx     : std_logic;
signal baud_en_tx     : std_logic;
signal rx_active      : std_logic;	
signal tx_activee     : std_logic;

component u_rx	generic(
osc_freq              : integer := 100_000_000;
width                 : integer := 8;
no_of_sample          : integer := 16
);

port(
--------------- INPUTS --------------------------------------------
	
clk                   :in std_logic;	
data_in               :in std_logic;
baud_en_rx            :in std_logic;
		
--------------- OUTPUTS --------------------------------------------		

rx_active             :out std_logic;
data_out              :out std_logic_vector(width-1 downto 0):= (others =>'0');
data_ready            :out std_logic


	);
end component u_rx;

component u_tx is
generic(
osc_freq              : integer := 100_000_000;
width                 : integer := 8;
no_of_sample          : integer := 16
);


port(
--------------- INPUTS --------------------------------------------
	
clk                   :in std_logic;	
send                  :in std_logic;
data_in               :in std_logic_vector( (width-1) downto 0);
baud_en_tx            :in std_logic;

--------------- OUTPUTS --------------------------------------------		

tx_active             :out std_logic;
data_out              :out std_logic


);
end component u_tx;

component baudrate_gen is	

generic(
osc_freq              : integer := 100_000_000;
width                 : integer := 8;
no_of_sample          : integer := 16
);



port(	
--------------- INPUTS --------------------------------------------
	
clk                   :in std_logic;	
sw                    :in std_logic_vector(2 downto 0);
rx_active             :in std_logic;
tx_active             :in std_logic;

--------------- OUTPUTS --------------------------------------------		

baud_en_rx            :out std_logic;
baud_en_tx            :out std_logic	
);
end component baudrate_gen; 
  
  
begin
---------------------------- INSTANTIATE BAUDRATE GENERATOR -------------------------------	
BAUDRATE : baudrate_gen generic map (
no_of_sample           => no_of_sample,
osc_freq               => osc_freq
)
port map (
clk                    => clk,
sw                     => sw,
rx_active              => rx_active,
tx_active              => tx_activee,
baud_en_rx             => baud_en_rx,
baud_en_tx             => baud_en_tx			
); 
---------------------------- INSTANTIATE UART RECEIVER -------------------------------	
U_RECEIVE : u_rx generic map (
width                  => width, 
no_of_sample           => no_of_sample
)
port map (
clk                    => clk,
data_in                => rx_din,
baud_en_rx             => baud_en_rx,
rx_active              => rx_active,
data_out               => rx_data,
data_ready             => rx_data_ready
);
---------------------------- INSTANTIATE UART TRANSMITTER -------------------------------	
U_TRANSMIT : u_tx generic map (
width                  => width, 
no_of_sample           => no_of_sample
)
port map (
clk                    => clk,
send                   =>tx_send,
data_in                => tx_data,
baud_en_tx             => baud_en_tx,
data_out               => tx_dout,
tx_active              => tx_activee
);

tx_active              <= tx_activee;
end architecture struct; 

