`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: AMAL K AYYAN
// 
// Create Date: 22.10.2023 12:09:08
// Design Name: 
// Module Name: camera_capture_tb
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

module camera_capture_tb;

    // Inputs
    reg pclk;
    reg vsync;
    reg href;
    reg [7:0] data;
    reg done;

    // Outputs
    wire [18:0] pix_addr;
    wire [11:0] pix_data;

    // Instantiate the module
    camera_capture dut (
        .pclk(pclk),
        .vsync(vsync),
        .href(href),
        .data(data),
        .done(done),
        .pix_addr(pix_addr),
        .pix_data(pix_data)
    );
  
  integer i,j;

    // Clock Generation
    always #5 pclk = ~pclk;

    initial begin
        pclk = 0;
        vsync = 0;
        href = 0;
        data = 0;
        done = 0;
        #5;

        // Initializing the first frame
        vsync = 1;
        #10;
        vsync = 0;
        #10;

        // Simulating 10 frames
        for ( i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                href = 1;
                data = j*10; // Simulating some data
                #20;
                data = 0; // Simulating some data
                href = 0;
                #10;
            end
            
            if(i >= 1) // skip 2 frames
            #10
            done = 1; // Activating done signal after the initial two frames

            else
            done = 0; // Activating done signal after the initial two frames
            
            vsync = 1; // Simulating vsync for the end of the frame
            #10;
            vsync = 0;
        end

    end

endmodule

