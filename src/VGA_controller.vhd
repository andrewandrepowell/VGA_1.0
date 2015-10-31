----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2015 08:36:50 PM
-- Design Name: 
-- Module Name: VGA_controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity VGA_controller is
    generic (
        C_m_axi_fb_BURST_LEN    : integer    := 256;
        C_m_axi_fb_DATA_WIDTH    : integer    := 64;
        C_m_axi_fb_ADDR_WIDTH    : integer    := 32;
        C_s_axi_config_DATA_WIDTH	: integer	:= 32;
        BITS_PER_PE : integer := 4;
        BG_B_COLOR : std_logic_vector(3 downto 0) := "0000";
        BG_G_COLOR : std_logic_vector(3 downto 0) := "0000";
        BG_R_COLOR : std_logic_vector(3 downto 0) := "0000");
    port (
        clock : in std_logic;
        reset : in std_logic;
        vga_h_display : in std_logic;
        vga_v_display : in std_logic;
        vga_b : out std_logic_vector(BITS_PER_PE-1 downto 0) := BG_B_COLOR;
        vga_g : out std_logic_vector(BITS_PER_PE-1 downto 0) := BG_G_COLOR;
        vga_r : out std_logic_vector(BITS_PER_PE-1 downto 0) := BG_R_COLOR;
        axi_fb_di_address : out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
        axi_fb_enable : out std_logic;
        axi_fb_ready : in std_logic;
        axi_fb_di_ready : in std_logic;
        axi_fb_di_data : in std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
        address_reg : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
        start_reg : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0));
end VGA_controller;

architecture Behavioral of VGA_controller is

    constant MIN_WORD_WIDTH : integer := 32;
    constant MIN_WORDS_PER_WORD : integer := C_m_axi_fb_DATA_WIDTH/MIN_WORD_WIDTH;
    constant DS_VGA_WIDTH : integer := 1;
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;
    constant BITS_PER_BYTE : integer := 8;
    constant BYTES_PER_PIXEL : integer := 2;
    constant BYTES_PER_ROW : integer := SCREEN_WIDTH*BYTES_PER_PIXEL;
    constant BYTES_PER_FRAME : integer := BYTES_PER_ROW*SCREEN_HEIGHT;
    constant BITS_PER_PIXEL : integer := BYTES_PER_PIXEL*BITS_PER_BYTE;
    constant PIXELS_PER_WORD : integer := C_m_axi_fb_DATA_WIDTH/BITS_PER_BYTE/BYTES_PER_PIXEL;
    constant PIXELS_PER_MIN_WORD : integer :=  PIXELS_PER_WORD/MIN_WORDS_PER_WORD;
    constant PIXELS_PER_BURST : integer := C_m_axi_fb_BURST_LEN*PIXELS_PER_WORD;    
    
    --type pixel_buffer_type is array (0 to PIXELS_PER_BURST-1) of std_logic_vector(BITS_PER_PIXEL-1 downto 0);
    --signal pixel_buffer : pixel_buffer_type;
    signal pixel_buffer : std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
    
    signal clock_vga : std_logic;
    signal vga_h_v_display : std_logic;
    signal vga_synch : std_logic;
    type vga_state_type is (S_VGA_SYNCH_V_H,S_VGA_GAT,S_VGA_PRINT,S_VGA_SYNCH_H);
    signal vga_state : vga_state_type := S_VGA_SYNCH_V_H;
    
    signal gat_address_base : unsigned(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
    signal gat_enable : std_logic;
    signal gat_ready : std_logic;
    type gat_state_type is (S_GAT_ENABLE,S_GAT_AXI_FB,S_GAT_READY);
    signal gat_state : gat_state_type := S_GAT_ENABLE;
    
    signal axi_fb_di_address_buff : std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
    signal axi_fb_enable_buff : std_logic;
    
    signal blk_wea : std_logic;
    signal blk_wea_slv : std_logic_vector(0 downto 0);
    signal blk_addra : std_logic_vector(7 downto 0);
    signal blk_dina : std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
    signal blk_addrb : std_logic_vector(7 downto 0);
    signal blk_doutb : std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
    
    component DownSample is
        generic (    
            WIDTH                : integer := 1);
        port (        
            clock                : in std_logic;
            reset                : in std_logic;
            output            : out std_logic);
    end component;
    
    component blk_mem_gen_pixel is
        port (
            clka : in std_logic;
            wea : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(7 downto 0);
            dina : in std_logic_vector(63 downto 0);
            clkb : in std_logic;
            addrb : in std_logic_vector(7 downto 0);
            doutb : out std_logic_vector(63 downto 0));
    end component;

begin

    -- Block Memory for Pixels
    blk_mem_gen_pixel_0 : blk_mem_gen_pixel
        port map (
            clka => clock,
            wea => blk_wea_slv,
            addra => blk_addra,
            dina => blk_dina,
            clkb => clock,
            addrb => blk_addrb,
            doutb => blk_doutb);

    -- VGA Clock
    DownSample_0 : DownSample 
        generic map (    
            WIDTH => DS_VGA_WIDTH)
        port map (        
            clock => clock,
            reset => reset,
            output => clock_vga);

    -- Print to VGA Operation
    vga_h_v_display <= vga_h_display and vga_v_display;
    process (clock_vga)
        variable pixel_pointer : 
            integer range 0 to PIXELS_PER_BURST := 0;
        variable i :
            integer range 0 to PIXELS_PER_WORD := 0;
        variable min_word_pointer :
            integer range 0 to MIN_WORDS_PER_WORD := 0;
        variable word_pointer : 
            integer range 0 to C_m_axi_fb_BURST_LEN := 0; 
    begin
        if (rising_edge(clock_vga)) then
            if (reset='1') then
                vga_state <= S_VGA_SYNCH_V_H;
                gat_address_base <= (others => '0');
                gat_enable <= '0';
                vga_synch <= '0';
                vga_b <= BG_B_COLOR;
                vga_g <= BG_G_COLOR;
                vga_r <= BG_R_COLOR;
                pixel_buffer <= (others => '0');
                blk_addrb <= (others => '0');
                pixel_pointer := 0;
                i := 0;
                min_word_pointer := 0;
                word_pointer := 0;
            else
                case vga_state is
                    when S_VGA_SYNCH_V_H =>
                        if (vga_h_v_display='0' and start_reg(0)='1') then
                            vga_state <= S_VGA_GAT;
                            gat_address_base <= (others => '0');
                        end if;
                    when S_VGA_GAT =>
                        if (gat_enable='1' and gat_ready='1') then
                            vga_state <= S_VGA_PRINT;
                            gat_enable <= '0';
                        else
                            gat_enable <= '1';
                        end if;
                    when S_VGA_PRINT =>
                        if (vga_h_v_display='1') then
                            pixel_buffer <= blk_doutb;
                            blk_addrb <= std_logic_vector(to_unsigned(
                                word_pointer,blk_addrb'length));
                            vga_b <= pixel_buffer(
                                (BITS_PER_PE-1)+(i*BITS_PER_PIXEL) downto 
                                0+(i*BITS_PER_PIXEL));
                            vga_g <= pixel_buffer(
                                (BITS_PER_PE*2-1)+(i*BITS_PER_PIXEL) downto
                                 BITS_PER_PE+(i*BITS_PER_PIXEL));
                            vga_r <= pixel_buffer(
                                (BITS_PER_PE*3-1)+(i*BITS_PER_PIXEL) downto 
                                BITS_PER_PE*2+(i*BITS_PER_PIXEL));
                            vga_synch <= '1';
                            pixel_pointer := pixel_pointer+1;
                            word_pointer := pixel_pointer/PIXELS_PER_WORD;
                            min_word_pointer := MIN_WORDS_PER_WORD-1-
                                ((pixel_pointer/PIXELS_PER_MIN_WORD) mod MIN_WORDS_PER_WORD);
                            i := (pixel_pointer mod PIXELS_PER_MIN_WORD)+min_word_pointer*2;
                        elsif (vga_synch='1') then 
                            vga_b <= BG_B_COLOR;
                            vga_g <= BG_G_COLOR;
                            vga_r <= BG_R_COLOR;
                            vga_state <= S_VGA_SYNCH_H;
                            pixel_pointer := 0;
                            i := 0;
                            word_pointer := 0;
                            min_word_pointer := 0;
                            vga_synch <= '0';
                        end if;
                    when S_VGA_SYNCH_H =>
                        gat_address_base <= gat_address_base+BYTES_PER_ROW;
                        if (vga_v_display='0') then
                            vga_state <= S_VGA_SYNCH_V_H;
                        else
                            vga_state <= S_VGA_GAT;
                        end if;
                    when others =>
                        vga_state <= S_VGA_SYNCH_V_H;
                end case;
            end if;
        end if;
    end process;
    
    -- Fill Buffer Operation
    axi_fb_di_address <= axi_fb_di_address_buff;
    axi_fb_enable <= axi_fb_enable_buff;
    blk_wea_slv <= (0 => blk_wea);
    process (clock)
        variable word_pointer : integer range 0 to C_m_axi_fb_BURST_LEN := 0; 
    begin
        if (rising_edge(clock)) then
            if (reset='1') then
                gat_state <= S_GAT_ENABLE;
                gat_ready <= '0';
                axi_fb_di_address_buff <= (others => '0');
                axi_fb_enable_buff <= '0';
                word_pointer := 0;
            else
                case gat_state is
                    when S_GAT_ENABLE =>
                        gat_ready <= '0';
                        if (gat_enable='1') then
                            axi_fb_di_address_buff <= 
                                std_logic_vector(unsigned(address_reg)+
                                gat_address_base);
                            gat_state <= S_GAT_AXI_FB;
                            word_pointer := 0;
                        end if;
                    when S_GAT_AXI_FB =>
                        if (axi_fb_enable_buff='1' and axi_fb_ready='1') then
                            gat_state <= S_GAT_READY;
                            blk_wea <= '0';
                            axi_fb_enable_buff <= '0';
                        elsif (axi_fb_di_ready='1') then
                            blk_wea <= '1';
                            blk_addra <= std_logic_vector(to_unsigned(word_pointer,blk_addra'length));
                            blk_dina <= axi_fb_di_data;
                            word_pointer := word_pointer+1;
                        else
                            axi_fb_enable_buff <= '1';
                        end if;
                    when S_GAT_READY =>
                        gat_ready <= '1';
                        if (gat_enable='0') then
                            gat_state <= S_GAT_ENABLE;
                        end if;
                    when others =>
                        gat_state <= S_GAT_ENABLE;
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;


                                
