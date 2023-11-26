`timescale 1ns / 1ns

module cam_config_tb;

reg clk;
reg rst;
reg start_cam_config;

wire done_cam_config;
wire siod;
wire sioc;
wire one_phase_done;

localparam T_CLK = 10; //10ns

cam_config uut
(   clk,
    rst, 
    start_cam_config,
    done_cam_config,
    siod, 
    sioc,
    one_phase_done
);

initial begin
    clk = 0;
    rst = 1;
    start_cam_config = 0;
end

always #(T_CLK/2) clk = ~clk;

initial begin
    rst = 0;
    #100
    rst = 1;
    #100
    start_cam_config = 1;
    #50
    start_cam_config = 0;
end
  
endmodule