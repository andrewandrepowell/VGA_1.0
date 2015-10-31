----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2015 04:27:40 PM
-- Design Name: 
-- Module Name: axi_config_controller - Behavioral
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


entity axi_config_controller is
    generic (
        -- Default Address Reg
        C_m_axi_fb_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
        -- Parameters of Axi Slave Bus Interface s_axi_config
        C_s_axi_config_DATA_WIDTH    : integer    := 32;
        C_s_axi_config_ADDR_WIDTH    : integer    := 4);
    port (
        -- Synchronization 
        axi_aclk	: in std_logic;
        axi_aresetn    : in std_logic;
        -- Data
        address_reg : out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
        error_reg : in std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
        start_reg  : out std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);
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
        s_axi_config_rready	: in std_logic);
end axi_config_controller;

architecture Behavioral of axi_config_controller is

    constant BITS_PER_BYTE : integer := 8;
    constant ADDR_ADDRESS_REG : integer := 0;
    constant ADDR_ERROR_REG : integer := 1;
    constant ADDR_START_REG : integer := 2;
    signal address_reg_buff : std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0) :=
        C_m_axi_fb_TARGET_SLAVE_BASE_ADDR;
    signal start_reg_buff : std_logic_vector(C_s_axi_config_DATA_WIDTH-1 downto 0);

    type state_axiw_type is (AXIW_S_WRITE_ADDRESS,AXIW_S_WRITE_PROCESS,
        AXIW_S_WRITE_DATA,AXIW_S_WRITE_RESPONSE);
    signal state_axiw : state_axiw_type := AXIW_S_WRITE_ADDRESS;
    signal s_axi_config_awready_buff : std_logic;
    signal s_axi_config_wready_buff : std_logic;
    signal s_axi_config_bvalid_buff : std_logic;
    signal s_axi_config_bresp_buff : std_logic_vector(1 downto 0);
    signal s_axi_config_awaddr_buff : std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
    signal s_axi_config_awaddr_select : std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 2);
    signal s_axi_config_awprot_buff : std_logic_vector(2 downto 0);
    
    type state_axir_type is (AXIR_S_WRITE_ADDRESS,AXIR_S_READ_PROCESS,AXIR_S_READ_DATA);
    signal state_axir : state_axir_type := AXIR_S_WRITE_ADDRESS;
    signal s_axi_config_arready_buff : std_logic;
    signal s_axi_config_rvalid_buff : std_logic;
    signal s_axi_config_rresp_buff : std_logic_vector(1 downto 0);
    signal s_axi_config_araddr_buff : std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 0);
    signal s_axi_config_araddr_select : std_logic_vector(C_s_axi_config_ADDR_WIDTH-1 downto 2);
    signal s_axi_config_arprot_buff : std_logic_vector(2 downto 0);

begin

    address_reg <= address_reg_buff;
    start_reg <= start_reg_buff;

    -- Write AXI Operation
    s_axi_config_awready <= s_axi_config_awready_buff;
    s_axi_config_wready <= s_axi_config_wready_buff;
    s_axi_config_bvalid <= s_axi_config_bvalid_buff;
    s_axi_config_bresp <= s_axi_config_bresp_buff;
    s_axi_config_awaddr_select <= s_axi_config_awaddr_buff(
            s_axi_config_awaddr_buff'high downto 
            s_axi_config_awaddr_buff'low+2);
    process (axi_aclk) 
    begin
        if (rising_edge(axi_aclk)) then
            if (axi_aresetn='0') then
                state_axiw <= AXIW_S_WRITE_ADDRESS;
                s_axi_config_awready_buff <= '0';
                s_axi_config_wready_buff <= '0';
                s_axi_config_bvalid_buff <= '0';
                s_axi_config_bresp_buff <= (others => '0');
                s_axi_config_awaddr_buff <= (others => '0');
                s_axi_config_awprot_buff <= (others => '0');
                address_reg_buff <= C_m_axi_fb_TARGET_SLAVE_BASE_ADDR;
                start_reg_buff <= (others => '0');
            else
                case state_axiw is
                    when AXIW_S_WRITE_ADDRESS =>
                        if (s_axi_config_awready_buff='1' and s_axi_config_awvalid='1') then
                            state_axiw <= AXIW_S_WRITE_PROCESS;
                            s_axi_config_awaddr_buff <= s_axi_config_awaddr;
                            s_axi_config_awprot_buff <= s_axi_config_awprot;
                            s_axi_config_awready_buff <= '0';
                        else
                            s_axi_config_awready_buff <= '1';
                        end if;
                    when AXIW_S_WRITE_PROCESS =>
                        -- Check for errors.
                        if ((s_axi_config_awaddr_buff(1 downto 0)/="00") or
                                (s_axi_config_awprot_buff(2)/='0')) then
                            s_axi_config_bresp_buff <= "10";
                        else
                            s_axi_config_bresp_buff <= "00";
                        end if;
                        state_axiw <= AXIW_S_WRITE_DATA;
                    when AXIW_S_WRITE_DATA =>
                        if (s_axi_config_wready_buff='1' and s_axi_config_wvalid='1') then
                            -- Write data based on address.
                            for i in 0 to s_axi_config_wstrb'high loop
                                if (to_integer(unsigned(s_axi_config_awaddr_select))=
                                        ADDR_ADDRESS_REG) then
                                    if (s_axi_config_wstrb(i)='1') then
                                        address_reg_buff(BITS_PER_BYTE*(i+1)-1 downto 
                                            i*BITS_PER_BYTE) <= 
                                            s_axi_config_wdata(BITS_PER_BYTE*(i+1)-1 downto 
                                            i*BITS_PER_BYTE);
                                    end if;
                                elsif (to_integer(unsigned(s_axi_config_awaddr_select))=
                                        ADDR_START_REG) then
                                    start_reg_buff(BITS_PER_BYTE*(i+1)-1 downto 
                                            i*BITS_PER_BYTE) <= 
                                            s_axi_config_wdata(BITS_PER_BYTE*(i+1)-1 downto 
                                            i*BITS_PER_BYTE);
                                end if;
                            end loop;
                            s_axi_config_wready_buff <= '0';
                            state_axiw <= AXIW_S_WRITE_RESPONSE;
                        else
                            s_axi_config_wready_buff <= '1';
                        end if;
                    when AXIW_S_WRITE_RESPONSE =>
                        if (s_axi_config_bvalid_buff='1' and s_axi_config_bready='1') then
                            s_axi_config_bvalid_buff <= '0';
                            state_axiw <= AXIW_S_WRITE_ADDRESS;
                        else
                            s_axi_config_bvalid_buff <= '1';
                        end if;
                    when others =>
                        state_axiw <= AXIW_S_WRITE_ADDRESS;
                end case;
            end if;
        end if;
    end process;

    -- Read AXI Operation
    s_axi_config_arready <= s_axi_config_arready_buff;
    s_axi_config_rvalid <= s_axi_config_rvalid_buff;
    s_axi_config_rresp <= s_axi_config_rresp_buff;
    s_axi_config_araddr_select <= s_axi_config_araddr_buff(
        s_axi_config_araddr_buff'high downto 
        s_axi_config_araddr_buff'low+2);
    process (axi_aclk)
    begin
        if (rising_edge(axi_aclk)) then
            if (axi_aresetn='0') then
                state_axir <= AXIR_S_WRITE_ADDRESS;
                s_axi_config_araddr_buff <= (others => '0');
                s_axi_config_arprot_buff <= (others => '0');
                s_axi_config_arready_buff <= '0';
                s_axi_config_rvalid_buff <= '0';
                s_axi_config_rdata <= (others => '0');
                s_axi_config_rresp_buff <= (others => '0');
            else
                case state_axir is
                    when AXIR_S_WRITE_ADDRESS =>
                        if (s_axi_config_arready_buff='1' and
                                s_axi_config_arvalid='1') then
                            state_axir <= AXIR_S_READ_PROCESS;
                            s_axi_config_araddr_buff <= s_axi_config_araddr;
                            s_axi_config_arprot_buff <= s_axi_config_arprot;
                            s_axi_config_arready_buff <= '0';
                        else
                            s_axi_config_arready_buff <= '1';
                        end if;
                    when AXIR_S_READ_PROCESS =>
                        -- Check for errors.
                        if ((s_axi_config_araddr_buff(1 downto 0)/="00") or
                                (s_axi_config_arprot_buff(2)/='0')) then
                            s_axi_config_rresp_buff <= "10";
                        else
                            s_axi_config_rresp_buff <= "00";
                        end if;
                        -- Read data based on address.
                        if (to_integer(unsigned(s_axi_config_araddr_select))=
                                ADDR_ADDRESS_REG) then
                            s_axi_config_rdata <= address_reg_buff;
                        elsif (to_integer(unsigned(s_axi_config_araddr_select))=
                                ADDR_ERROR_REG) then
                            s_axi_config_rdata <= error_reg;
                        elsif (to_integer(unsigned(s_axi_config_araddr_select))=
                                ADDR_START_REG) then
                            s_axi_config_rdata <= start_reg_buff;
                        else
                            s_axi_config_rdata <= (others => '0');
                        end if;
                        state_axir <= AXIR_S_READ_DATA;
                    when AXIR_S_READ_DATA =>
                        if (s_axi_config_rvalid_buff='1' and 
                                s_axi_config_rready='1') then
                            state_axir <= AXIR_S_WRITE_ADDRESS;
                            s_axi_config_rvalid_buff <= '0';
                        else
                            s_axi_config_rvalid_buff <= '1';
                        end if;
                    when others =>
                        state_axir <= AXIR_S_WRITE_ADDRESS;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
