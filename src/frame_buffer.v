`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2023 01:26:25
// Design Name: 
// Module Name: frame_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



/* frame_buffer is used to store data temperorly until it 
   is read.

   It has 640*480 rows. Each row is of 12-bit.
   
   Infer dual-port BRAM with dual clocks:
    https://docs.xilinx.com/v/u/2019.2-English/ug901-vivado-synthesis (page 126)*/
   
module frame_buffer 
 (
    input wire rd_clk,
    input wire rd_en,
    input wire [18:0] rd_addr,

    input wire wr_clk,
    input wire wr_en,
    input wire [18:0] wr_addr,

    input wire bram_en,
    input wire [11:0]data_in,
    output reg [11:0]data_out

);

// Declaring a ram.
localparam WIDTH = 12 ;
localparam DEPTH = 640*480;
reg [WIDTH - 1: 0]bram[0:DEPTH - 1];

  

// To read data from bram
always @(posedge rd_clk ) begin
        if(rd_en)
            data_out <= bram[rd_addr];
end
  


  
// To write data to ram.
always @(posedge wr_clk ) begin
        if(bram_en)
            if(wr_en)
                bram[wr_addr] <= data_in ;
end
    
endmodule
