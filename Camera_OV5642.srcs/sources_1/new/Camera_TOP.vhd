
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Camera_TOP is
    Port ( 
    clk : in std_logic;
    butt_in : in std_logic;
    SDA : inout std_logic;
    SCL : out std_logic
    );
end Camera_TOP;

architecture rtl of Camera_TOP is
    constant c_Clock_Frequency   : integer := 100000000; -- 100 MHz clock
    constant c_I2C_Frequency     : integer := 100000;
    
begin
I2C_mod : entity work.I2C_MOD
    generic map(
        Clock_Frequency => c_Clock_Frequency,
        I2C_Frequency => c_I2C_Frequency)
    port map(
        clk => clk,
        I2C_begin => butt_in, 
        I2C_SDA => SDA,
        I2C_SCL => SCL);
end rtl;
