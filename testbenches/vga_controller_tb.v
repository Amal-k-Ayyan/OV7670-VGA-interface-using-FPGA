`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2023 03:02:54
// Design Name: 
// Module Name: vga_controller_tb
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


module vga_controller_tb;
    reg pclk;
    reg rst;
  	wire [9:0]x;
 	wire [9:0]y;
    wire video_on;
    wire hsync;
    wire vsync;

    localparam P_CLK = 40; //40ns

     vga_controller uut
    (
        .pclk(pclk),
        .rst(rst),
        .x(x), 
        .y(y),
        .video_on(video_on),
        .hsync(hsync),
        .vsync(vsync)
    );

initial begin
    pclk = 0;
    rst = 0;
end

  always #(P_CLK/2) pclk = ~pclk;

initial begin
    rst = 0;
    #100
    rst = 1;
    
end


endmodule