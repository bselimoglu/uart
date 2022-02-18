LIBRARY IEEE ;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity u_tx is 
generic(
osc_freq              : integer range 0 to 100000000 := 100_000_000;
width                 : integer range 0 to 8 := 8;
no_of_sample          : integer range 0 to 16 := 16
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
end u_tx;
--------------- ARCHITECTURE ---------------------------------------
architecture behav of u_tx is

type tx_state_type is (idle, send_start_bit, send_data, send_stop_bit);
signal State          : tx_state_type := idle;

signal tx_baud_cnt    : integer range 0 to no_of_sample := 0;
signal tx_bit_index   : integer range 0 to (width-1):=0;
signal tx_data	      : std_logic_vector((width-1)downto 0) := (others => '0');


begin

-------------- FSM OF TRANSMITTER---------------------------------------------

process(clk)

begin

if rising_edge(clk) then 
case State is
------------------IDLE------------------
  when idle =>
  
    tx_active         <= '0';
    data_out          <= '1';
    tx_baud_cnt       <= 0;
    tx_bit_index      <= 0;
    
    if send = '1' then
    
      tx_data         <= data_in;
      tx_active       <= '1';
      State           <= send_start_bit;
      
    else
    
      State           <= idle;
      
    end if;
------------------START------------------	
  when send_start_bit =>
  
  tx_active           <= '1';
  data_out            <= '0';
  
  if baud_en_tx = '1' then 
  
    if tx_baud_cnt < no_of_sample-1 then
    
      tx_baud_cnt     <= tx_baud_cnt + 1 ;
      State           <= send_start_bit;
          
    else
    
      tx_baud_cnt     <= 0;
      State           <= send_data;
          
    end if;
    
  else
  
    State             <= send_start_bit;
    
  end if;
------------------TRANSMIT DATA------------------
  when send_data=> 
  
    tx_active         <= '1';
    data_out          <= tx_data(tx_bit_index);
    
    if baud_en_tx = '1' then 
    
      if tx_baud_cnt < no_of_sample-1 then
      
        tx_baud_cnt   <= tx_baud_cnt + 1;
        State         <= send_data ;
        
      else
      
        tx_baud_cnt   <= 0;        
        if tx_bit_index <(width-1) then
        
          tx_bit_index<= tx_bit_index +1;
          State       <= send_data;
          
        else 
        
          tx_bit_index<= 0;
          State       <= send_stop_bit;
          
        end if;
        
      end if;	
      
    else 
    
      State           <= send_data;
      
    end if;
    
------------------STOP------------------
  when send_stop_bit=> 
  
  data_out            <= '1';
  if baud_en_tx = '1' then
  
    if tx_baud_cnt < no_of_sample-1 then 
    
      tx_baud_cnt     <= tx_baud_cnt + 1;
      State           <= send_stop_bit;
    else
    
      State           <= idle;
      tx_baud_cnt     <= 0;
      tx_active       <= '0';

    end if;
    
  else 	
  
    State             <= send_stop_bit;
    
  end if;
------------------DONE------------------
  when others =>
  
  State               <= idle;
  
end case;
  
else

  State               <= State;
  
end if;

end process;


end architecture behav;
