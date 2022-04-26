# Camera-OV5642
Camera OV5642 connection with FPGA Basys3 board via SPI and display video in real time on VGA monitor.

Being written in VHDL Vivado for Basys 3 board. The idea of the project is to allow communication between OV5642 camera and Basys3 board via SPI. 
Then image will be displayed on vga monitor in real time. 

Design architecture:

![alt text](https://raw.githubusercontent.com/Wanils/Camera-OV5642/main/scheme.png)

As one can see module consists of:
- PLL module to lower the frequency from 100 MHz to 25 MHz.
- I2C module needed to properly configure camera
- SPI module needed for data transmission
- FIFO to allow fluent crossing clock domain
- VGA modules

Project is still in progress. Current activities: developing I2C module on branch: I2C_feature.
