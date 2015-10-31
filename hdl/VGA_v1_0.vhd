----------------------------------------------------------------------------------
-- Company: System Chip Design Lab (SCDL) of Temple University College of Engineering
-- Engineer: Andrew Powell
-- 
-- Create Date: 10/12/2015 08:36:50 PM
-- Design Name: 
-- Module Name: VGA_v1_0 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: The VGA_v1_0 AXI-wrapped IP is intended to provide a memory-mapped 
-- interface to the Avnet Zedboard's 4-bit VGA interface, although the VGA_v1_0 IP
-- could be adapted to any platform with a VGA interface. The resolution is 480x640.
-- The interfaces include "s_axi_config", a slave 32-bit AXI4-Lite interface for 
-- configuration; "m_axi_fb", a maseter 64-bit AXI4-Full interface for reading the 
-- pixel data from memory; and a vga interface which consists of the horizontal and
-- vertical synchronization signals, and the rgb interface for pixels.
-- 
-- Dependencies: Consider every file included in the folder VGA_1.0\ as a dependency. 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_v1_0 is
    generic (
        -- Parameters of Axi Slave Bus Interface s_axi_config
        C_s_axi_config_DATA_WIDTH	: integer	:= 32;
        C_s_axi_config_ADDR_WIDTH	: integer	:= 4;
        -- Parameters of Axi Master Bus Interface m_axi_fb
        C_m_axi_fb_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"00000000";
        C_m_axi_fb_BURST_LEN	: integer	:= 256;
        C_m_axi_fb_ID_WIDTH	: integer	:= 1;
        C_m_axi_fb_ADDR_WIDTH	: integer	:= 32;
        C_m_axi_fb_DATA_WIDTH	: integer	:= 64;
        C_m_axi_fb_AWUSER_WIDTH	: integer	:= 0;
        C_m_axi_fb_ARUSER_WIDTH	: integer	:= 0;
        C_m_axi_fb_WUSER_WIDTH	: integer	:= 0;
        C_m_axi_fb_RUSER_WIDTH	: integer	:= 0;
        C_m_axi_fb_BUSER_WIDTH	: integer	:= 0;
        -- 
        BITS_PER_PE : integer := 4);
	port (
        -- Synchronization 
        axi_aclk	: in std_logic; -- 100 MHz clock
        axi_aresetn    : in std_logic;
        -- VGA Interface
        h_sync : out std_logic;
        v_sync : out std_logic;
        vga_b : out std_logic_vector(BITS_PER_PE-1 downto 0);
        vga_g : out std_logic_vector(BITS_PER_PE-1 downto 0);
        vga_r : out std_logic_vector(BITS_PER_PE-1 downto 0);
        -- Ports of Axi Slave Bus Interface s_axi_config
        s_axi_config_awaddr	: in std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
        s_axi_config_awprot	: in std_logic_vector(2 downto 0);
        s_axi_config_awvalid	: in std_logic;
        s_axi_config_awready	: out std_logic;
        s_axi_config_wdata	: in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
        s_axi_config_wstrb	: in std_logic_vector((C_s_axi_config_DATA_WIDTH/8)-1 downto 0);
        s_axi_config_wvalid	: in std_logic;
        s_axi_config_wready	: out std_logic;
        s_axi_config_bresp	: out std_logic_vector(1 downto 0);
        s_axi_config_bvalid	: out std_logic;
        s_axi_config_bready	: in std_logic;
        s_axi_config_araddr	: in std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
        s_axi_config_arprot	: in std_logic_vector(2 downto 0);
        s_axi_config_arvalid	: in std_logic;
        s_axi_config_arready	: out std_logic;
        s_axi_config_rdata	: out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
        s_axi_config_rresp	: out std_logic_vector(1 downto 0);
        s_axi_config_rvalid	: out std_logic;
        s_axi_config_rready	: in std_logic;
		-- Ports of Axi Master Bus Interface m_axi_fb
		m_axi_fb_awid	: out std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
		m_axi_fb_awaddr	: out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
		m_axi_fb_awlen	: out std_logic_vector(7 downto 0);
		m_axi_fb_awsize	: out std_logic_vector(2 downto 0);
		m_axi_fb_awburst	: out std_logic_vector(1 downto 0);
		m_axi_fb_awlock	: out std_logic;
		m_axi_fb_awcache	: out std_logic_vector(3 downto 0);
		m_axi_fb_awprot	: out std_logic_vector(2 downto 0);
		m_axi_fb_awqos	: out std_logic_vector(3 downto 0);
		m_axi_fb_awuser	: out std_logic_vector(C_m_axi_fb_AWUSER_WIDTH-1 downto 0);
		m_axi_fb_awvalid	: out std_logic;
		m_axi_fb_awready	: in std_logic;
		m_axi_fb_wdata	: out std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
		m_axi_fb_wstrb	: out std_logic_vector(C_m_axi_fb_DATA_WIDTH/8-1 downto 0);
		m_axi_fb_wlast	: out std_logic;
		m_axi_fb_wuser	: out std_logic_vector(C_m_axi_fb_WUSER_WIDTH-1 downto 0);
		m_axi_fb_wvalid	: out std_logic;
		m_axi_fb_wready	: in std_logic;
		m_axi_fb_bid	: in std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
		m_axi_fb_bresp	: in std_logic_vector(1 downto 0);
		m_axi_fb_buser	: in std_logic_vector(C_m_axi_fb_BUSER_WIDTH-1 downto 0);
		m_axi_fb_bvalid	: in std_logic;
		m_axi_fb_bready	: out std_logic;
		m_axi_fb_arid	: out std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
		m_axi_fb_araddr	: out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
		m_axi_fb_arlen	: out std_logic_vector(7 downto 0);
		m_axi_fb_arsize	: out std_logic_vector(2 downto 0);
		m_axi_fb_arburst	: out std_logic_vector(1 downto 0);
		m_axi_fb_arlock	: out std_logic;
		m_axi_fb_arcache	: out std_logic_vector(3 downto 0);
		m_axi_fb_arprot	: out std_logic_vector(2 downto 0);
		m_axi_fb_arqos	: out std_logic_vector(3 downto 0);
		m_axi_fb_aruser	: out std_logic_vector(C_m_axi_fb_ARUSER_WIDTH-1 downto 0);
		m_axi_fb_arvalid	: out std_logic;
		m_axi_fb_arready	: in std_logic;
		m_axi_fb_rid	: in std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
		m_axi_fb_rdata	: in std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
		m_axi_fb_rresp	: in std_logic_vector(1 downto 0);
		m_axi_fb_rlast	: in std_logic;
		m_axi_fb_ruser	: in std_logic_vector(C_m_axi_fb_RUSER_WIDTH-1 downto 0);
		m_axi_fb_rvalid	: in std_logic;
		m_axi_fb_rready	: out std_logic);
end VGA_v1_0;

architecture arch_imp of VGA_v1_0 is

    constant DS_VGA_WIDTH : integer := 1;
    signal clock_vga : std_logic;
    signal address_reg : std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
    signal error_reg : std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
    signal start_reg : std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
    signal vga_v_display : std_logic;
    signal vga_h_display : std_logic;
    signal axi_fb_enable : std_logic;
    signal axi_fb_ready : std_logic;
    signal axi_fb_di_address : std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
    signal axi_fb_di_ready : std_logic;
    signal axi_fb_di_data : std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);

    component VGA is
        port (
            clock : in std_logic; 
            reset : in std_logic;
            h_display : out std_logic;
            h_sync : out std_logic;
            v_display : out std_logic;
            v_sync : out std_logic);
    end component;

    component VGA_controller is
        generic (
            BITS_PER_PE : integer := BITS_PER_PE;
            C_m_axi_fb_BURST_LEN    : integer    := C_m_axi_fb_BURST_LEN;
            C_m_axi_fb_DATA_WIDTH    : integer    := C_m_axi_fb_DATA_WIDTH;
            C_m_axi_fb_ADDR_WIDTH    : integer    := C_m_axi_fb_ADDR_WIDTH;
            C_s_axi_config_DATA_WIDTH	: integer	:= C_s_axi_config_DATA_WIDTH);
        port (
            clock : in std_logic;
            reset : in std_logic;
            vga_h_display : in std_logic;
            vga_v_display : in std_logic;
            vga_b : out std_logic_vector(BITS_PER_PE-1 downto 0);
            vga_g : out std_logic_vector(BITS_PER_PE-1 downto 0);
            vga_r : out std_logic_vector(BITS_PER_PE-1 downto 0);
            axi_fb_di_address : out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
            axi_fb_enable : out std_logic;
            axi_fb_ready : in std_logic;
            axi_fb_di_ready : in std_logic;
            axi_fb_di_data : in std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
            address_reg : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            start_reg  : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0));
    end component;

    component axi_fb_controller is
        generic (
            C_m_axi_fb_BURST_LEN : integer := C_m_axi_fb_BURST_LEN;
            C_m_axi_fb_ID_WIDTH : integer := C_m_axi_fb_ID_WIDTH;
            C_m_axi_fb_ADDR_WIDTH : integer := C_m_axi_fb_ADDR_WIDTH;
            C_m_axi_fb_DATA_WIDTH : integer := C_m_axi_fb_DATA_WIDTH;
            C_m_axi_fb_AWUSER_WIDTH : integer := C_m_axi_fb_AWUSER_WIDTH;
            C_m_axi_fb_ARUSER_WIDTH : integer := C_m_axi_fb_ARUSER_WIDTH;
            C_m_axi_fb_WUSER_WIDTH : integer := C_m_axi_fb_WUSER_WIDTH;
            C_m_axi_fb_RUSER_WIDTH : integer := C_m_axi_fb_RUSER_WIDTH;
            C_m_axi_fb_BUSER_WIDTH : integer := C_m_axi_fb_BUSER_WIDTH;
            C_s_axi_config_DATA_WIDTH : integer	:= C_s_axi_config_DATA_WIDTH);
        port (
            axi_aclk    : in std_logic;
            axi_aresetn    : in std_logic;
            enable : in std_logic;
            ready : out std_logic;
            di_ready : out std_logic;
            di_address : in std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
            di_data : out std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
            error_reg : out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            m_axi_fb_awid    : out std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
            m_axi_fb_awaddr    : out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
            m_axi_fb_awlen    : out std_logic_vector(7 downto 0);
            m_axi_fb_awsize    : out std_logic_vector(2 downto 0);
            m_axi_fb_awburst    : out std_logic_vector(1 downto 0);
            m_axi_fb_awlock    : out std_logic;
            m_axi_fb_awcache    : out std_logic_vector(3 downto 0);
            m_axi_fb_awprot    : out std_logic_vector(2 downto 0);
            m_axi_fb_awqos    : out std_logic_vector(3 downto 0);
            m_axi_fb_awuser    : out std_logic_vector(C_m_axi_fb_AWUSER_WIDTH-1 downto 0);
            m_axi_fb_awvalid    : out std_logic;
            m_axi_fb_awready    : in std_logic;
            m_axi_fb_wdata    : out std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
            m_axi_fb_wstrb    : out std_logic_vector(C_m_axi_fb_DATA_WIDTH/8-1 downto 0);
            m_axi_fb_wlast    : out std_logic;
            m_axi_fb_wuser    : out std_logic_vector(C_m_axi_fb_WUSER_WIDTH-1 downto 0);
            m_axi_fb_wvalid    : out std_logic;
            m_axi_fb_wready    : in std_logic;
            m_axi_fb_bid    : in std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
            m_axi_fb_bresp    : in std_logic_vector(1 downto 0);
            m_axi_fb_buser    : in std_logic_vector(C_m_axi_fb_BUSER_WIDTH-1 downto 0);
            m_axi_fb_bvalid    : in std_logic;
            m_axi_fb_bready    : out std_logic;
            m_axi_fb_arid    : out std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
            m_axi_fb_araddr    : out std_logic_vector(C_m_axi_fb_ADDR_WIDTH-1 downto 0);
            m_axi_fb_arlen    : out std_logic_vector(7 downto 0);
            m_axi_fb_arsize    : out std_logic_vector(2 downto 0);
            m_axi_fb_arburst    : out std_logic_vector(1 downto 0);
            m_axi_fb_arlock    : out std_logic;
            m_axi_fb_arcache    : out std_logic_vector(3 downto 0);
            m_axi_fb_arprot    : out std_logic_vector(2 downto 0);
            m_axi_fb_arqos    : out std_logic_vector(3 downto 0);
            m_axi_fb_aruser    : out std_logic_vector(C_m_axi_fb_ARUSER_WIDTH-1 downto 0);
            m_axi_fb_arvalid    : out std_logic;
            m_axi_fb_arready    : in std_logic;
            m_axi_fb_rid    : in std_logic_vector(C_m_axi_fb_ID_WIDTH-1 downto 0);
            m_axi_fb_rdata    : in std_logic_vector(C_m_axi_fb_DATA_WIDTH-1 downto 0);
            m_axi_fb_rresp    : in std_logic_vector(1 downto 0);
            m_axi_fb_rlast    : in std_logic;
            m_axi_fb_ruser    : in std_logic_vector(C_m_axi_fb_RUSER_WIDTH-1 downto 0);
            m_axi_fb_rvalid    : in std_logic;
            m_axi_fb_rready    : out std_logic);
    end component;

    component axi_config_controller is
        generic (
            C_m_axi_fb_TARGET_SLAVE_BASE_ADDR : std_logic_vector := C_m_axi_fb_TARGET_SLAVE_BASE_ADDR;
            C_s_axi_config_DATA_WIDTH : integer := C_s_axi_config_DATA_WIDTH;
            C_s_axi_config_ADDR_WIDTH : integer := C_s_axi_config_ADDR_WIDTH);
        port (
            axi_aclk	: in std_logic;
            axi_aresetn    : in std_logic;
            address_reg : out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            error_reg : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            start_reg : out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            s_axi_config_awaddr	: in std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
            s_axi_config_awprot	: in std_logic_vector(2 downto 0);
            s_axi_config_awvalid	: in std_logic;
            s_axi_config_awready	: out std_logic;
            s_axi_config_wdata	: in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            s_axi_config_wstrb	: in std_logic_vector((C_s_axi_config_DATA_WIDTH/8)-1 downto 0);
            s_axi_config_wvalid	: in std_logic;
            s_axi_config_wready	: out std_logic;
            s_axi_config_bresp	: out std_logic_vector(1 downto 0);
            s_axi_config_bvalid	: out std_logic;
            s_axi_config_bready	: in std_logic;
            s_axi_config_araddr	: in std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
            s_axi_config_arprot	: in std_logic_vector(2 downto 0);
            s_axi_config_arvalid	: in std_logic;
            s_axi_config_arready	: out std_logic;
            s_axi_config_rdata	: out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
            s_axi_config_rresp	: out std_logic_vector(1 downto 0);
            s_axi_config_rvalid	: out std_logic;
            s_axi_config_rready	: in std_logic);
    end component;
   
begin
    
    -- VGA Clock
    process (axi_aclk) 
    begin
        if (rising_edge(axi_aclk)) then
            if (axi_aresetn='0') then
                clock_vga <= '0';
            else
                clock_vga <= not clock_vga;
            end if;
        end if;
    end process;

    VGA_0: VGA 
        port map (
            clock => clock_vga,
            reset => "not"(axi_aresetn),
            h_display => vga_h_display,
            h_sync => h_sync,
            v_display => vga_v_display,
            v_sync => v_sync);

    VGA_controller_0: VGA_controller 
        port map (
            clock => axi_aclk,
            reset => "not"(axi_aresetn),
            vga_h_display => vga_h_display,
            vga_v_display => vga_v_display,
            vga_b => vga_b,
            vga_g => vga_g,
            vga_r => vga_r,
            axi_fb_di_address => axi_fb_di_address,
            axi_fb_enable => axi_fb_enable,
            axi_fb_ready => axi_fb_ready,
            axi_fb_di_ready => axi_fb_di_ready,
            axi_fb_di_data => axi_fb_di_data,
            address_reg => address_reg,
            start_reg => start_reg);

    axi_fb_controller_0: axi_fb_controller 
        port map (
            axi_aclk => axi_aclk,
            axi_aresetn => axi_aresetn,
            enable => axi_fb_enable,
            ready => axi_fb_ready,
            di_ready => axi_fb_di_ready,
            di_address => axi_fb_di_address,
            di_data => axi_fb_di_data,
            error_reg => error_reg,
            m_axi_fb_awid => m_axi_fb_awid,
            m_axi_fb_awaddr => m_axi_fb_awaddr,
            m_axi_fb_awlen => m_axi_fb_awlen,
            m_axi_fb_awsize => m_axi_fb_awsize,
            m_axi_fb_awburst => m_axi_fb_awburst,
            m_axi_fb_awlock => m_axi_fb_awlock,
            m_axi_fb_awcache => m_axi_fb_awcache,
            m_axi_fb_awprot => m_axi_fb_awprot,
            m_axi_fb_awqos => m_axi_fb_awqos,
            m_axi_fb_awuser => m_axi_fb_awuser,
            m_axi_fb_awvalid => m_axi_fb_awvalid,
            m_axi_fb_awready => m_axi_fb_awready,
            m_axi_fb_wdata => m_axi_fb_wdata,
            m_axi_fb_wstrb => m_axi_fb_wstrb,
            m_axi_fb_wlast => m_axi_fb_wlast,
            m_axi_fb_wuser => m_axi_fb_wuser,
            m_axi_fb_wvalid => m_axi_fb_wvalid,
            m_axi_fb_wready => m_axi_fb_wready,
            m_axi_fb_bid => m_axi_fb_bid,
            m_axi_fb_bresp => m_axi_fb_bresp,
            m_axi_fb_buser => m_axi_fb_buser,
            m_axi_fb_bvalid => m_axi_fb_bvalid,
            m_axi_fb_bready => m_axi_fb_bready,
            m_axi_fb_arid => m_axi_fb_arid,
            m_axi_fb_araddr => m_axi_fb_araddr,
            m_axi_fb_arlen => m_axi_fb_arlen,
            m_axi_fb_arsize => m_axi_fb_arsize,
            m_axi_fb_arburst => m_axi_fb_arburst,
            m_axi_fb_arlock => m_axi_fb_arlock,
            m_axi_fb_arcache => m_axi_fb_arcache,
            m_axi_fb_arprot => m_axi_fb_arprot,
            m_axi_fb_arqos => m_axi_fb_arqos,
            m_axi_fb_aruser => m_axi_fb_aruser,
            m_axi_fb_arvalid => m_axi_fb_arvalid,
            m_axi_fb_arready => m_axi_fb_arready,
            m_axi_fb_rid => m_axi_fb_rid,
            m_axi_fb_rdata => m_axi_fb_rdata,
            m_axi_fb_rresp => m_axi_fb_rresp,
            m_axi_fb_rlast => m_axi_fb_rlast,
            m_axi_fb_ruser => m_axi_fb_ruser,
            m_axi_fb_rvalid => m_axi_fb_rvalid,
            m_axi_fb_rready => m_axi_fb_rready);

    axi_config_controller_0: axi_config_controller 
        port map (
            axi_aclk => axi_aclk,
            axi_aresetn => axi_aresetn,
            address_reg => address_reg,
            error_reg => error_reg,
            start_reg => start_reg,
            s_axi_config_awaddr	=> s_axi_config_awaddr,
            s_axi_config_awprot => s_axi_config_awprot,
            s_axi_config_awvalid => s_axi_config_awvalid,
            s_axi_config_awready => s_axi_config_awready,
            s_axi_config_wdata => s_axi_config_wdata,
            s_axi_config_wstrb => s_axi_config_wstrb,
            s_axi_config_wvalid => s_axi_config_wvalid,
            s_axi_config_wready => s_axi_config_wready,
            s_axi_config_bresp => s_axi_config_bresp,
            s_axi_config_bvalid => s_axi_config_bvalid,
            s_axi_config_bready => s_axi_config_bready,
            s_axi_config_araddr => s_axi_config_araddr,
            s_axi_config_arprot => s_axi_config_arprot,
            s_axi_config_arvalid => s_axi_config_arvalid,
            s_axi_config_arready => s_axi_config_arready,
            s_axi_config_rdata => s_axi_config_rdata,
            s_axi_config_rresp => s_axi_config_rresp,
            s_axi_config_rvalid => s_axi_config_rvalid,
            s_axi_config_rready => s_axi_config_rready);

end arch_imp;
