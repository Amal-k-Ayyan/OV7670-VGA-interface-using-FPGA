`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2023 01:55:43
// Design Name: 
// Module Name: sccb
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


/*NOTE: If we use pullup resistors for SCL and SDL, then SCL and SDL data must be inverted.

-- This module collects data from ROM and
        then passes to SCCB. Data includes OVA7670
        register address and register configuration data.

    -- The rom data is 16-bit wide. Lower 8-bits
        is data and upper 8-bit is register address.
        ie., rom_data = {sccb_sub_addr, sccb_data}
     
    -- After reseting registers, a 10ms delay is given
        for changes to settle.

    -- After we sent each address and data, we should wait for
        one clk cycle delay for changes to settle.



*/
/*--------------------------------------------------------------------------------------------------------------------------*/

module sccb

// port declaration
(  input wire clk,
   input wire sccb_start, // When SET we start to send data.
   input wire [7:0]sub_address,
   input wire [7:0]data,

   output reg sccb_ready, // set HIGH if ready to receive data.
   output reg one_phase_done, // Made high after each phase is written
   output reg siod,
   output reg sioc

);

// register for storing incoming 8-bit address and data.
reg [7:0]r_sub_address;
reg [7:0]r_data;

parameter clk_freq = 100_000_000; //100MHz
parameter sccb_freq =  400_000; //400KHz  

/*-----------------------------------------------------*/

// we load the each of 3 phase data to this reg before transimitting serially.
reg [7:0]tx_byte;

localparam CAM_ADDR = 8'h42; // CAMERA ADDRESS

/*-----------------------------------------------------*/
/*siod have to be synchronized with sioc. But we take system clock as reference.
  So to synchronize with sioc, we find how many clock cycles of system clock
  contributes to one cycle of sioc,*/

localparam TIMER_WIDTH = 8; /*$clog2(clk_freq/sccb_freq)*/
localparam HALF = 5;//clk_freq/(2*sccb_freq);
localparam QUARTER = 2;//clk_freq/(4*sccb_freq);

/*-----------------------------------------------------*/

reg [TIMER_WIDTH - 1:0]timer;  // to keep track of delay
reg [4:0]state; // to keep track of fsm states
reg [4:0]return_state; // Timer is used by many states. So we also specify return state to go from Timer.
reg [3:0]bit_index; // for indexing bits of tx_byte.
reg [1:0]phase_counter; //to keep track of 3 phase data.

/*-----------------------------------------------------*/


/* Fsm states*/
localparam IDLE = 0;
localparam START1 = 1 ; //siod low
localparam START2 = 2 ; //sioc low
localparam LOAD_BYTE = 3;
localparam TX_BYTE1 = 4;
localparam TX_BYTE2 = 5;
localparam TX_BYTE3 = 6;
localparam TX_BYTE4 = 7;
localparam DONE = 8;
localparam END1 = 9 ;
localparam END2 = 10;
localparam TIMER = 11;

initial begin
    sioc <= 1'b1;
    siod <= 1'b1;
    sccb_ready <= 1'b1;

    state <= IDLE; 
    return_state <= IDLE; 
end

always @(posedge clk) begin
    
    case (state)
        IDLE: begin 
            timer <= 0;
             bit_index <= 0;
             phase_counter <= 0;
             sccb_ready <= 1;
             one_phase_done <= 0;

             if(sccb_start) begin
                state <= START1;
                r_sub_address <= sub_address; // Load incoming 8-bit address to a register..
                r_data <= data; //Load incoming data to a register..
                //sccb_ready <= 0;
             end
                
        end //IDLE

        START1: begin  // Bring SDA line low and wait for half cycle of SCL.
            siod <= 0;
            sioc <= 1;
            
            timer <= HALF;
            state <= TIMER;
            return_state <= START2;

        end //START1

         START2: begin  // Bring SCL line low and wait for half cycle of SCL.
            siod <= 0;
            sioc <= 0;
            
            timer <= HALF;
            state <= TIMER;
            return_state <= LOAD_BYTE;

        end //START2

/* loading the register with data. We are not transmitting anything here.*/
        LOAD_BYTE: begin 
            sioc <= 0;
            siod <= 0;

            phase_counter <= phase_counter + 1;
            bit_index <= 0;
            state <= (phase_counter == 3)? END1:TX_BYTE1;
            
            case(phase_counter)
            0: tx_byte <= CAM_ADDR;
            1: tx_byte <= r_sub_address;
            2: tx_byte <= r_data;
            default: tx_byte <= r_data;
            endcase
            

        end //LOAD_BYTE


        /* In single iteration of below 4 stages, only single bit is transmitted.*/
        
        TX_BYTE1: begin // Load each bit to SDA when SCL is LOW.
            sioc <= 0; // Ensure scl is low when SDA changes.
            siod <= tx_byte[7];

            timer <= QUARTER; 
            state <= TIMER;
            return_state <= TX_BYTE2;

        end //TX_BYTE1

        TX_BYTE2: begin  //Now make SCL high and wait for Quarter time.
            sioc <= 1; 
            siod <= tx_byte[7];

            timer <= QUARTER; 
            state <= TIMER;
            return_state <= TX_BYTE3;

        end //TX_BYTE2

        TX_BYTE3: begin // Wait for Quarter time.(Same as previous state)
            sioc <= 1; 
            siod <= tx_byte[7];

            timer <= QUARTER;
            state <= TIMER;
            return_state <= TX_BYTE4;
            

        end //TX_BYTE3

        TX_BYTE4: begin // Make SCL LOW and wait for Quarter time.
            sioc <= 0; 
            siod <= tx_byte[7];

            if(bit_index == 8) begin
                one_phase_done <= 1; // done signal is made high for Quarter time.
                timer <= QUARTER;
                state <= TIMER;
                return_state <= DONE;
            end

            else begin
                bit_index <= bit_index + 1;
                tx_byte <= tx_byte << 1; // Shift each bit by one position to left.

                timer <= QUARTER;
                state <= TIMER;
                return_state <= TX_BYTE1;
            end

        end //TX_BYTE4

        DONE: begin // For sending acknowledge bit
            one_phase_done <= 0;
            sioc <= 0;
            siod <= 0;

            timer <= QUARTER; 
            state <= TIMER;
            return_state <= LOAD_BYTE;
           
        end //DONE


        END1: begin  // make SCL HIGH first
            sioc <= 1;
            siod <= 0;

            timer <= HALF;
            state <= TIMER;
            return_state <= END2;
           
        end //END1

        END2: begin  // Now make SDL HIGH
            sioc <= 1;
            siod <= 1;
            
            timer <= HALF; 
            state <= TIMER;
            return_state <= IDLE;
            
        end //END2

        TIMER: begin
            if(timer == 1)
                state <= return_state;
            else begin
                timer <= timer - 1;
                state <= TIMER;
            end
        end //TIMER
      
        default: state <= IDLE; 
    endcase  


end // always
endmodule
