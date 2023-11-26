`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2023 03:01:26
// Design Name: 
// Module Name: debouncer
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


// Slow clock for debouncing 
module clock_div
(
    input wire Clk_100M,
    output reg slow_clk
);
    reg [26:0]counter = 0;
    
    always @(posedge Clk_100M)
    begin
        counter <= (counter == 49 )? 0:counter+1; //24999999
        slow_clk <= (counter < 24)? 1'b0:1'b1;//12499999
    end
endmodule


// D-flip-flop for debouncing module 
module dff
(   input D,
    input clk,
    input sync_reset,
    output reg Q
);

always @(posedge clk) 
begin
 if(sync_reset == 1'b1)
  Q <= 1'b0; 
 else 
  Q <= D; 
end 
endmodule 

module debouncer
(   input  clk,
    input wire rst,
    input wire pb_in,
    output wire pb_out
 );


wire slow_clk;
wire Q1,Q2,Q2_bar,Q0;

clock_div u1(clk,slow_clk);
  
dff d0(rst, slow_clk, pb_in, Q0 );

dff d1(rst, slow_clk, Q0,Q1 );
  
dff d2(rst, slow_clk, Q1,Q2 );

assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2;

endmodule