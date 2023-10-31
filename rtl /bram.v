
/* Frame_buffer is to store the image data before sending it to the VGA controller. 
The frame buffer should manage the storage and retrieval of pixel data for each frame.

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

reg bram_data_in;
  

// To read data from ram
always @(posedge rd_clk ) begin
        if(rd_en)
            bram_data_in <= bram[rd_addr];
end
  
assign data_in = bram_data_in;

  
// To write data to ram.
always @(posedge wr_clk ) begin
        if(bram_en)
            if(wr_en)
                bram[rd_addr] <= data_in ;
end
    
endmodule


