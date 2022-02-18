LIBRARY IEEE ;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity u_rx is 
generic(
osc_freq              : integer range 0 to 100000000 := 100_000_000;
width                 : integer range 0 to 8 := 8;
no_of_sample          : integer range 0 to 16 := 16
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
end u_rx;

--------------- ARCHITECTURE ---------------------------------------

architecture behav of u_rx is

type rx_state_type is (idle, wait_mid_of_start_bit, receive_data, receive_stop_bit);
signal State          : rx_state_type := idle;

signal rx_baud_cnt	  : integer range 0 to 15 := 0;
signal rx_data_r      : std_logic;
signal rx_data	      : std_logic;
signal rx_bit_index	  : integer range 0 to (width-1):=0;
signal half_no_of_sample: integer range 0 to 8 := ((no_of_sample/2)-1);
signal rx_out_byte	  : std_logic_vector (width-1 downto 0):= (others =>'0');
signal rx_ready_data  : std_logic := '0';


begin 

-------------- DOUBLE REGISTER TO REMOVE METASTABILITY ---------------------------------------------

process(clk)

begin

if rising_edge(clk) then
  rx_data_r           <= data_in;
  rx_data             <= rx_data_r;			
end if;

end process;


-------------- FSM OF RECEIVER ---------------------------------------------

process(clk)

begin

if rising_edge(clk) then 
	rx_ready_data     <= '0';
case State is
------------------IDLE------------------
when idle =>

rx_active             <= '0';

if rx_data = '0' then

  State               <= wait_mid_of_start_bit;
  rx_baud_cnt         <= 0;
  rx_active           <= '1';

else
  State               <= idle;
end if;
------------------START------------------	
when wait_mid_of_start_bit =>

rx_active             <= '1';

if baud_en_rx = '1' then 

  if rx_baud_cnt = half_no_of_sample then
    if rx_data = '0' then
    
      rx_baud_cnt     <= 0;
      State           <= receive_data ;
      
    else
      State           <= idle;
    end if;
    
  else
    rx_baud_cnt       <= rx_baud_cnt + 1;
    State             <= wait_mid_of_start_bit ; 
    
  end if;
  
else 
  State               <= wait_mid_of_start_bit ;	
end if;
					------------------RECEIVE DATA------------------
          
when receive_data => 

rx_active <= '1';

if baud_en_rx = '1' then 
  if rx_baud_cnt < no_of_sample-1 then 
  
    rx_baud_cnt       <= rx_baud_cnt + 1;
    State             <= receive_data ;
    
  else
    rx_baud_cnt       <= 0;
    rx_out_byte(rx_bit_index) <= rx_data;
    
    if rx_bit_index <(width-1) then 
      rx_bit_index    <= rx_bit_index +1;
      State           <= receive_data;
      
    else 
      rx_bit_index    <= 0;
      State           <= receive_stop_bit;
      
    end if;
  end if;	
else 
  State               <= receive_data ;	
end if;
					------------------STOP------------------
when receive_stop_bit =>

rx_active <= '1';

if baud_en_rx = '1' then  

  if rx_baud_cnt < no_of_sample-1 then 
    rx_baud_cnt      <= rx_baud_cnt + 1;
    State            <= receive_stop_bit;
    
  else  
    if rx_data = '1' then    
      rx_ready_data  <= '1';
      rx_baud_cnt    <= 0;
      rx_active      <= '0';
      State          <= idle; 
      
    else
      rx_ready_data  <= '0';
      State          <= idle;
      
    end if;
  end if;
else
  State              <= receive_stop_bit; 
end if;
					------------------DONE------------------
when others =>
  State              <= idle;
end case;
  
else
  State              <= State;
end if;
end process;

data_ready           <= rx_ready_data;
data_out             <= rx_out_byte;

end architecture behav;
