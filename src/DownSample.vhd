----------------------------------------------------------------------------------
-- Company: System Chip Design Lab (Temple Univeristy Engineering)
-- Engineer: Andrew Powell
-- 
-- Create Date:    20:33:59 08/27/2015 
-- Design Name: 
-- Module Name:    DownSample - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL;		

entity DownSample is
	generic (	
		WIDTH				: integer := 1);
	port (		
		clock				: in std_logic;
		reset				: in std_logic;
		output			: out std_logic);
end DownSample;

architecture Behavioral of DownSample is
	signal counter 		: std_logic_vector((WIDTH-1) downto 0) :=
		conv_std_logic_vector(0,WIDTH);
	signal output_buff	: std_logic := '0';
begin
	output <= output_buff;
	process (clock)
	begin
		if (rising_edge(clock)) then
			if (reset='1') then
				output_buff <= '0';
				counter <= (others=>'0');
			else
				counter <= counter+1;
				if (counter=0) then
					output_buff <= not output_buff;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

