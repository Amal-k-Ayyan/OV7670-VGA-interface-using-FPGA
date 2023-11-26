`timescale 1ns/1ps
module sccb_tb;

    //inputs 
    reg tb_clk;
    reg tb_start;
    reg [7:0] tb_sub_address;
    reg [7:0] tb_data; 
    
    
    //outputs 
    wire tb_ready;
    wire tb_done;
    wire tb_sioc;
    wire tb_siod;
    
   sccb DUT (.clk(tb_clk),
             .sccb_start(tb_start),
             .sub_address(tb_sub_address),
             .data(tb_data),
             
             .sccb_ready(tb_ready),
             .one_phase_done(tb_done),
             .siod(tb_siod),
             .sioc(tb_sioc) );
    
    always #5 tb_clk = ~tb_clk;
    
    initial begin
        tb_clk = 0;
        tb_start = 0;
        tb_sub_address = 0;
        tb_data = 0;
        #20;
        tb_start = 1;
        tb_sub_address = 8'hAA;
        tb_data = 8'h77;
        
        #60;
        tb_start = 0;
        tb_sub_address = 0;
        tb_data = 0;
    end
     initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
    
endmodule