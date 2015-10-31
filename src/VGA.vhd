----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/10/2015 08:28:00 PM
-- Design Name: 
-- Module Name: VGA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity VGA is
    generic (
        COUNTER_WIDTH : integer := 10);
    port (
        clock : in std_logic; -- 50 MHz
        reset : in std_logic;
        h_display : out std_logic;
        h_sync : out std_logic;
        hor_counter : out std_logic_vector(COUNTER_WIDTH-1 downto 0);
        v_display : out std_logic;
        v_sync : out std_logic;
        ver_counter : out std_logic_vector(COUNTER_WIDTH-1 downto 0));
end VGA;

architecture Behavioral of VGA is

    constant HOR_BACK_VAL : integer := (48-1); 
    constant HOR_DISPLAY_VAL : integer := (640-1);
    constant HOR_FRONT_VAL : integer := (16-1);
    constant HOR_PW_VAL : integer := (96-1);
    constant VER_BACK_VAL : integer := (29-1); 
    constant VER_DISPLAY_VAL : integer := (480-1);
    constant VER_FRONT_VAL : integer := (10-1);
    constant VER_PW_VAL : integer := (2-1);
    
    type hor_state_type is (S_HOR_BACK_PORCH,S_HOR_DISPLAY,S_HOR_FRONT_PORCH,S_HOR_PW); 
    signal hor_state : hor_state_type := S_HOR_BACK_PORCH;
    type ver_state_type is (S_VER_BACK_PORCH,S_VER_DISPLAY,S_VER_FRONT_PORCH,S_VER_PW); 
    signal ver_state : ver_state_type := S_VER_BACK_PORCH;
    
    signal clock_hor : std_logic := '0';
    signal h_display_buff : std_logic := '0';
    signal h_sync_buff : std_logic := '1';
    signal hor_counter_buff : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
    
    signal clock_ver : std_logic := '0';
    signal v_display_buff : std_logic := '0';
    signal v_sync_buff : std_logic := '1';
    signal ver_counter_buff : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
    
begin

    process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset='1') then
                clock_hor <= '0';
            else
                clock_hor <= not clock_hor;
            end if;
        end if;
    end process;

    h_display <= h_display_buff;
    h_sync <= h_sync_buff;
    hor_counter <= hor_counter_buff;
    process (clock_hor)
    begin
        if (rising_edge(clock_hor)) then
            case hor_state is
                when S_HOR_BACK_PORCH =>
                    if (hor_counter_buff=HOR_BACK_VAL) then
                        hor_counter_buff <= (others => '0');
                        h_display_buff <= '1';
                        clock_ver <= '0';
                        hor_state <= S_HOR_DISPLAY;
                    else
                        hor_counter_buff <= hor_counter_buff+1;
                    end if;
                when S_HOR_DISPLAY =>
                    if (hor_counter_buff=HOR_DISPLAY_VAL) then
                        hor_counter_buff <= (others => '0');
                        h_display_buff <= '0';
                        clock_ver <= '1';
                        hor_state <= S_HOR_FRONT_PORCH;
                    else
                        hor_counter_buff <= hor_counter_buff+1;
                    end if;
                when S_HOR_FRONT_PORCH =>
                    if (hor_counter_buff=HOR_FRONT_VAL) then
                        hor_counter_buff <= (others => '0');
                        h_sync_buff <= '0';
                        hor_state <= S_HOR_PW;
                    else
                        hor_counter_buff <= hor_counter_buff+1;
                    end if;
                when S_HOR_PW =>
                    if (hor_counter_buff=HOR_PW_VAL) then
                        hor_counter_buff <= (others => '0');
                        h_sync_buff <= '1';
                        hor_state <= S_HOR_BACK_PORCH;
                    else
                        hor_counter_buff <= hor_counter_buff+1;
                    end if;
                when others =>
                    hor_state <= S_HOR_BACK_PORCH;
            end case;
        end if;
    end process;

    v_display <= v_display_buff;
    v_sync <= v_sync_buff;
    ver_counter <= ver_counter_buff;
    process (clock_ver)
    begin
        if (rising_edge(clock_ver)) then
            case ver_state is
                when S_VER_BACK_PORCH => 
                    if (ver_counter_buff=VER_BACK_VAL) then
                        ver_counter_buff <= (others => '0');
                        v_display_buff <= '1';
                        ver_state <= S_VER_DISPLAY;
                    else
                        ver_counter_buff <= ver_counter_buff+1;
                    end if;
                when S_VER_DISPLAY =>
                    if (ver_counter_buff=VER_DISPLAY_VAL) then
                        ver_counter_buff <= (others => '0');
                        v_display_buff <= '0';
                        ver_state <= S_VER_FRONT_PORCH;
                    else
                        ver_counter_buff <= ver_counter_buff+1;
                    end if;
                when S_VER_FRONT_PORCH =>
                    if (ver_counter_buff=VER_FRONT_VAL) then
                        ver_counter_buff <= (others => '0');
                        v_sync_buff <= '0';
                        ver_state <= S_VER_PW;
                    else
                        ver_counter_buff <= ver_counter_buff+1;
                    end if;
                when S_VER_PW  =>
                    if (ver_counter_buff=VER_PW_VAL) then
                        ver_counter_buff <= (others => '0');
                        v_sync_buff <= '1';
                        ver_state <= S_VER_BACK_PORCH;
                    else
                        ver_counter_buff <= ver_counter_buff+1;
                    end if;
                when others =>
                    ver_state <= S_VER_BACK_PORCH;
            end case;
        end if;
    end process;

end Behavioral;
