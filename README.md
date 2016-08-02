# VGA_1.0
AXI memory-mapped VGA module originally designed for the Avent Zedboard 

The VGA_1.0 is a AXI-wrapped IP developed with the Xilinx Vivado IP Packager tool. The purpose of VGA_1.0 is to provide a memory-mapped interface to the Avent Zedboard's 4-bit VGA interface. The advantage of having a memory-mapped interface, of course, is to completely abstract the hardware from a software application. Note that VGA_1.0 does rely on 2 KB of Xilinx block ram to buffer data, and each frame specified in the software driver require 1 MB of memory. The resolution is configured for 480x640.

Name: Andrew Powell
Example Repository: https://github.com/andrewandrepowell/VGA_example
Contact Email: andrew.powell@temple.edu
Project Website: www.powellprojectshowcase.com
