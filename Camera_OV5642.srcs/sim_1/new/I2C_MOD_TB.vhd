----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.02.2022 16:44:28
-- Design Name: 
-- Module Name: I2C_MOD_TB - sim
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


entity Camera_TOP_TB is
end Camera_TOP_TB;

architecture sim of Camera_TOP_TB is
    constant Clock_Frequency   : integer := 100000000; -- 100 MHz clock
    constant I2C_Frequency     : integer := 100000;
    signal clk       :  std_logic := '0';
    signal butt_in :  std_logic := '0';
    signal SDA   :  std_logic;
    signal SCL   :  std_logic;

    constant ClockPeriod      : time := 1000 ms / Clock_Frequency;

begin

    UUT: entity work.Camera_TOP(rtl)
    port map(
    clk     => clk,
    butt_in => butt_in,
    SDA     => SDA,
    SCL     => SCL);

    clk <= not clk after ClockPeriod / 2;
    process is
    begin
    wait for 1 ms;
    butt_in <= '1';
    wait for 1 ms;
    butt_in <= '0';
    wait for 1 ms;
    butt_in <= '1';
    wait for 1 ms;
    butt_in <= '0';
    wait for 1 ms;
    butt_in <= '1';
    wait for 1 ms;
    butt_in <= '0';
    wait for 1 ms;
    butt_in <= '1';
    wait;
    end process;
    
end sim;
