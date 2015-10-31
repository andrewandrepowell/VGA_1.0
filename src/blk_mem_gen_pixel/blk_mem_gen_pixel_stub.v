// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Thu Oct 15 13:30:45 2015
// Host        : ENG01329-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/xilinx/projects/projectsnake/ip_repo/vga_1.0/src/blk_mem_gen_pixel/blk_mem_gen_pixel_stub.v
// Design      : blk_mem_gen_pixel
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2015.2" *)
module blk_mem_gen_pixel(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[7:0],dina[63:0],clkb,addrb[7:0],doutb[63:0]" */;
  input clka;
  input [0:0]wea;
  input [7:0]addra;
  input [63:0]dina;
  input clkb;
  input [7:0]addrb;
  output [63:0]doutb;
endmodule
