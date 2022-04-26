----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.02.2022 15:58:56
-- Design Name: 
-- Module Name: I2C_MOD - rtl
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

entity I2C_MOD is
    generic (
    Clock_Frequency   : integer := 100000000; -- 100 MHz clock
    I2C_Frequency     : integer := 100000);
    port(
    clk       : in  std_logic;
    I2C_begin : in  std_logic;
    I2C_SDA   : inout std_logic;
    I2C_SCL   : out std_logic);
end I2C_MOD;

architecture rtl of I2C_MOD is
    signal s_I2C_SCL        : std_logic := '1';
    signal s_I2C_SCL_fe     : std_logic;
    signal s_I2C_SDA        : std_logic := '1';
    signal s_I2C_begin_d    : std_logic;
    signal s_I2C_begin_re   : std_logic;
    constant Cnt_max        : integer := Clock_Frequency/I2C_Frequency;
    signal s_counter_scl    : integer range 0 to Cnt_max/2 := 0;
    signal s_counter_sda    : integer range 0 to Cnt_max := 0;
    signal s_counter_send   : integer range 0 to 8 := 0;
    signal s_counter_state  : integer range 0 to Cnt_max*8 := 0;
    signal s_i2c_cnt        : integer range 0 to 7 := 0;
    signal s_RX_ACK         : std_logic;
    signal Data_sent        : std_logic := '0';
    signal s_flag           : boolean := false;
    signal s_address_hex    : std_logic_vector(7 downto 0) := x"3A";
    signal s_data_hex       : std_logic_vector(7 downto 0) := x"BB";

    type t_State is (Wait_SB, Start_seq, Start_Bit, TX_Address, TX_Read_Write, RX_ACK, T_Pause, TX_Data, T_Wait, Stop_seq, Stop_Bit);
    signal State : t_State := Wait_SB;
begin

I2C_SCL_Process : process (clk)
begin
    if rising_edge(clk) then
        case State is
            when Wait_SB =>
                s_I2C_SCL <= '1';
            when Start_seq =>
                s_I2C_SCL <= '1';
            when Start_Bit =>
                s_I2C_SCL <= '0';
            when T_Pause =>
                s_I2C_SCL <= '0';
            when T_Wait =>
                s_I2C_SCL <= '0';
            when Stop_Bit =>
                s_I2C_SCL <= '1';
            when Stop_seq =>
                s_I2C_SCL <= '1';
            when others =>
                if (s_counter_scl<Cnt_max/2 - 1) then
                    s_counter_scl <= s_counter_scl + 1;
                else
                    s_I2C_SCL <= not s_I2C_SCL;
                    s_counter_scl <= 0;
                end if;
        end case;
    end if;

end process I2C_SCL_Process;
I2C_SDA_Process : process (clk)
begin
    if rising_edge(clk) then
        case State is
            when Wait_SB =>
                s_I2C_SDA <= '1';
            when Start_seq =>
                s_I2C_SDA <= '0';
            when Start_Bit =>
                s_I2C_SDA <= '0';
            when TX_Address =>
                if (s_counter_sda<Cnt_max - 1) then
                    s_counter_sda <= s_counter_sda + 1;
                    s_I2C_SDA <= s_address_hex(6 - s_counter_send);
                else
                    s_counter_sda <= 0;
                    s_counter_send <= s_counter_send + 1;
                end if;
            when TX_Read_Write =>
                s_I2C_SDA <= '1';
            when RX_ACK =>
                s_RX_ACK <= s_I2C_SDA;
                s_counter_send <= 0;
            when T_Pause =>
                s_I2C_SDA <= '0';
            when TX_Data =>
                if (s_counter_sda<Cnt_max - 1) then
                    s_I2C_SDA <= s_data_hex(7 - s_counter_send);
                    s_counter_sda <= s_counter_sda + 1;
                else
                    s_counter_sda <= 0;
                    s_counter_send <= s_counter_send + 1;
                end if;
            when T_Wait =>
                s_I2C_SDA <= '0';
            when Stop_Bit =>
                s_I2C_SDA <= '0';
            when Stop_seq =>
                s_I2C_SDA <= '1';
        end case;
    end if;
end process I2C_SDA_Process;

State_Machine : process (clk)
begin
    if rising_edge(clk) then
    case State is
        when Wait_SB =>
            if(s_I2C_begin_re = '1') then
                State <= Start_seq;
            else
                State <= Wait_SB;
            end if;
        when Start_seq =>
            if (s_counter_state < Cnt_max/2 - 1) then
                State <= Start_seq;
                s_counter_state <= s_counter_state + 1;
            else
                State <= Start_Bit;
                s_counter_state <= 0;
            end if;
        when Start_Bit =>
            if (s_counter_state < Cnt_max/2 - 1) then
                State <= Start_Bit;
                s_counter_state <= s_counter_state + 1;
            else
                State <= TX_address;
                s_counter_state <= 0;
            end if;
        when TX_Address =>
            if (s_counter_state < Cnt_max*7 - 1) then
                    State <= TX_Address;
                    s_counter_state <= s_counter_state + 1;
            else
                    State <= TX_Read_Write;
                    s_counter_state <= 0;
            end if;
        when TX_Read_Write => 
            if (s_counter_state < Cnt_max - 1) then
                State <= TX_Read_Write;
                s_counter_state <= s_counter_state + 1;
            else
                State <= RX_ACK;
                s_counter_state <= 0;
            end if;
        when RX_ACK =>
            if (s_counter_state < Cnt_max - 1) then
                State <= RX_ACK;
                s_counter_state <= s_counter_state + 1;
            else
                if(Data_sent = '0') then
                    State <= T_Pause;
                elsif(Data_sent = '1') then
                    State <= T_Wait;
                end if;
                s_counter_state <= 0;
            end if;
        when T_Pause =>
            if (s_counter_state < Cnt_max - 1) then
                State <= T_Pause;
                s_counter_state <= s_counter_state + 1;
            else
                State <= TX_Data;
                s_counter_state <= 0;
            end if;
        when TX_Data =>
            if (s_counter_state < Cnt_max*8 - 1) then
                State <= TX_Data;
                s_counter_state <= s_counter_state + 1;
            else
                State <= RX_ACK;
                s_counter_state <= 0;
                Data_sent <= '1';
            end if;
        when T_Wait =>
            if (s_counter_state < Cnt_max/2 - 1) then
                State <= T_Wait;
                s_counter_state <= s_counter_state + 1;
            else
                State <= Stop_Bit;
                s_counter_state <= 0;
            end if;
        when Stop_Bit =>
            if (s_counter_state < Cnt_max/2 - 1) then
                State <= Stop_Bit;
                s_counter_state <= s_counter_state + 1;
            else
                State <= Stop_seq;
                s_counter_state <= 0;
            end if;
        when Stop_seq =>
            State <= Wait_SB;
            Data_sent <= '0';
        end case;
    end if;
end process State_Machine;

s_I2C_begin_d <= I2C_begin when rising_edge(clk);
s_I2C_begin_re <= not s_I2C_begin_d and I2C_begin; 
I2C_SCL <= s_I2C_SCL;
I2C_SDA <= s_I2C_SDA;

end rtl;
