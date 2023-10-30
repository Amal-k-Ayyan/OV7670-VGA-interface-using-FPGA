`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: AMAL K AYYAN
// 
// Create Date: 22.10.2023 12:07:11
// Design Name: 
// Module Name: camera_capture
// Project Name: camera_capture
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



/* DESCRIPTION:Module to capture the frames.

vsync, href and pclk are driven by OVA7670.


data ouput of camera (input to module)is in the format RGB444:
       1st byte: { X, X, X, X, R[3], R[2], R[1], R[0]}
      2nd byte: {G[3], G[2], G[1], G[0], B[3], B[2], B[1], B[0]
ie of 8-bits each.

Output of module will be of the format:
            {RRRR GGGG BBBB} ie 12-bits.
*/

module camera_capture
    (
        input wire pclk, // pixel clock.
        input wire vsync, // vertical synchronization.
        input wire href, //or hsync horizontal synchronization.
        input [7:0] data, // input data from camera in RGB444 format.
        input wire done, // well be active after the first two frames.

        output reg [18:0] pix_addr, // stores address of each pixel. ceil(log((3,07,200), 2)) = 19
        output reg [11:0] pix_data // 12-bit output RGB data.
        //output reg wr


    );
  /*---------------------------------------------------------------------------
     DESCRIPTION: To get posedge and negedge of vsync.
  ----------------------------------------------------------------------------*/
  
   /* r1_vsync stores present value and r2_vsyc stores 
    previous value of vsync respectively.*/

    reg r1_vsync, r2_vsync;

    initial begin
        r1_vsync = 0;
        r2_vsync = 0;
    end
   
        always @(posedge pclk) begin
        r2_vsync <= r1_vsync;
        r1_vsync <= vsync;
    end

/*start_frame and end_frame indicates starting and ending of vsync signal respectively*/

    wire start_frame, end_frame;

    assign start_frame = (r2_vsync == 1) &&(r1_vsync == 0); // Negetive edge of vsync
    assign end_frame = (r2_vsync == 0) &&(r1_vsync == 1);   // positive edge of vsync

//------------------------------------------------------------------------
    
   // FSM
   localparam WAIT = 0;
   localparam IDLE = 1;
   localparam FRAME_CAPTURE = 2;

   reg flag = 0;
   reg [1:0]state = 0;
   reg [3:0]red_bits = 0; // To store 4-bit RED data.

always @(negedge pclk) begin

    case(state)

//skips first two VGA frames. done is active after initial 2 frames are skipped.

    WAIT: begin 
        state <= (start_frame && done)? IDLE: WAIT;
    end// WAIT

    IDLE: begin // wait until vsyc is LOW.
        pix_addr <= 0;
        pix_data <= 0;
        state <= (start_frame)? FRAME_CAPTURE: IDLE;
    end //IDLE


/* when flag = 0, module captures first 4 bits ie.. RED bits. 
   When flag = 1, module captures next 8-bits ie GREEN and BLUE bits*/

/* since each pixel is of 2 bytes, pix_addr increments only after 2nd 
   byte is received ie when flag = 1.*/

    FRAME_CAPTURE: begin // To capture the frame

        pix_addr <= (flag == 1)? pix_addr + 1: pix_addr;

        if (href == 1) begin // check if href is HIGH.

            red_bits <= (flag == 0)? data[3:0]: red_bits; 

            /*if(flag == 0) 
            red_bits <= data[3:0]; // First 4-bits of 1st byte.*/

            flag <= ~flag;
            pix_data <= (flag == 1)? {red_bits,data}: pix_data; 
        end
        state <= (end_frame)? IDLE:FRAME_CAPTURE;

    end //FRAME_CAPTURE

    endcase
end
endmodule

