`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2023 01:44:05
// Design Name: 
// Module Name: cam_top
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


module cam_top (
    input wire clk, // input clk
    input wire rst, // To reset the module

    input wire cam_start, //Input from push button
   // output reg cam_config_done,  // Output LED


    // Inputs from camera
    input wire pclk, // input from OVA 
    input [7:0] pix_data_in,
    input href,
    input vsync,

    // Outputs to camera
    output wire reset,
    output wire pwd,
    output wire siod,
    output wire sioc,


    //output to frame_buffer

    output wire pix_wr,
    output wire [11:0]pix_data_out,
    output wire [18:0] pix_addr



);

    wire cam_config_done;

/*  For reset,
     0: reset registers      
     1: normal mode

   For pwd,
    0: normal mode   
    1: power down mode
   */

    assign reset = 1;
    assign pwd = 0;

    wire cam_start_db; // Debounced output of push button.

    // pass the input of push button to a debouncer

    debouncer M4
    (
    .clk(clk),
    .rst(rst),
    .pb_in(cam_start),
    .pb_out(cam_start_db)         
    );

    cam_config M5
    (
    .clk(clk),
    .rst(rst),

    .start_cam_config(cam_start_db),
    .done_cam_config(cam_config_done),

    .siod(siod),
    .sioc(sioc),

    .one_phase_done() // testbunch purpose
    
);

camera_capture M6
    (
        .pclk(pclk), 
        .vsync(vsync),
        .href(href), 
        .pix_data_in(pix_data_in), 
        .done(cam_config_done), 

        .pix_addr(pix_addr), 
        .pix_data_out(pix_data_out),
        .wr(pix_wr)
        

    );

endmodule
