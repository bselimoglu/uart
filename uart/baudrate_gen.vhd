LIBRARY IEEE ;
LIBRARY WORK ;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.WAVE_GEN_PKG.ALL;

entity baudrate_gen is 
	 
generic(
osc_freq              : integer range 0 to 100000000 := 100_000_000;
width                 : integer range 0 to 8 := 8;
no_of_sample          : integer range 0 to 16 := 16
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
end baudrate_gen; 

--------------- ARCHITECTURE ---------------------------------------

architecture behav of baudrate_gen is

signal cnt_lim,cnt    : integer range 0 to 1000 := 0;
 


begin 

-------------- TICK ENABLE -----------------------------------------

process(clk,sw)

begin

if rising_edge(clk) then
  baud_en_rx          <= '0';
  baud_en_tx          <= '0';		  
  case sw is
  
	when "001" => cnt_lim <= CNT_LIMITS(1);
	when "010" => cnt_lim <= CNT_LIMITS(2);
	when "011" => cnt_lim <= CNT_LIMITS(3);
	when "100" => cnt_lim <= CNT_LIMITS(4);
	when others =>cnt_lim <= CNT_LIMITS(0);

  end case;
  
  if rx_active = '1' then
  
    if cnt > cnt_lim - 1 then
      baud_en_rx      <= '1';
      cnt             <= 0;
    else
      cnt             <= cnt + 1;
      baud_en_rx      <= '0';	
    end if;
    
  end if;
  
  if tx_active = '1' then
  
    if cnt > cnt_lim - 1 then
      baud_en_tx        <= '1';
      cnt               <= 0;
    else
      cnt               <= cnt + 1;
      baud_en_tx        <= '0';
    end if;
    
  end if;
    
  end if;	
  
end process;

end architecture behav ;

