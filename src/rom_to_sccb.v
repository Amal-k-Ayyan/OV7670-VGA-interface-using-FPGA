/*  -- This module collects data from ROM and
        then passes to SCCB. Data includes OVA7670
        register address and register configuration data.

    -- The rom data is 16-bit wide. Lower 8-bits
        is data and upper 8-bit is register address.
        ie., rom_data = {sccb_sub_addr, sccb_data}
     
    -- After reseting registers, a 10ms delay is given
        for changes to settle.

    -- After we sent each address and data, we should wait for
        one clk cycle delay for changes to settle.*/

module rom_to_sccb
    (
        input wire clk,
        input wire rst,
        input wire sccb_ready,
        input wire config_start,
        input wire [15:0]rom_data,

        output reg [7:0]rom_addr,
        output reg sccb_start,
        output reg [7:0]sccb_sub_addr, //OVA7670  register address
        output reg [7:0]sccb_data, // Data to config OVA7670  register
        output reg config_done
        
    );

    parameter clk_freq = 100000000; //100MHz

    // Timer to create 10ms delay
    localparam ten_ms = 1000000; // 10ms delay, count  = 10^6
    localparam timer_size = $clog2(ten_ms);

    /*-----------------------------------------------------*/

    reg [timer_size - 1:0]r_timer;  // to keep track of delay
    reg [1:0]r_state; // to keep track of fsm states
    reg [1:0]r_return_state; // Timer is used by many states. So we also specify return state to go from Timer.
    reg [1:0]r_phase_counter; //to keep track of 3 phase data.

    /*-----------------------------------------------------*/

    // FSM states
    localparam S_IDLE = 0;
    localparam S_SEND = 1;
    localparam S_DONE = 2;
    localparam S_TIMER = 3;

    /*-----------------------------------------------------*/

    always @(posedge clk or negedge rst) 
    begin

        if(!rst) begin
            r_state <= 0;
            r_return_state <= 0;

            rom_addr <= 0;
            sccb_start <= 0;
            sccb_sub_addr <= 0;
            sccb_data <= 0;
            r_phase_counter <= 0;
        
            config_done <= 0;
        end

        else begin

          case(r_state)
                S_IDLE: begin

                    rom_addr <= 0;
                    sccb_start <= 0;
                    sccb_sub_addr <= 0;
                    sccb_data <= 0;
                    r_phase_counter <= 0;

                    r_state <= (config_start)? S_SEND: S_IDLE;
                end //S_IDLE

                S_SEND: begin
                    if(sccb_ready) begin
                        case(rom_data)
                            16'hFF_F0: r_state <= S_DONE; // End of rom

                            16'hFF_F0: begin // create 10ms delay after reseting registers
                                r_state <= S_TIMER;
                                r_timer <= ten_ms;
                                r_return_state <= S_SEND;

                                rom_addr <= rom_addr + 1;
                            end

                            default: begin
                                sccb_data <= rom_data[7:0];
                                sccb_sub_addr <= rom_data[15:8];
                                rom_addr <= rom_addr + 1;

                                // wait for 1-clk cycle
                                r_state <= S_TIMER;
                                r_return_state <= S_SEND;
                                r_timer <= 1;
                            end
                        endcase
                    end
                end //S_SEND

                S_DONE: begin
                    r_state <= S_IDLE;
                    config_done <= 1;
                end //S_DONE

                S_TIMER: begin
                    r_timer <= (r_timer == 1)? 1: r_timer - 1;
                    r_state <= (r_timer == 1)? r_return_state: S_TIMER;
                end //S_TIMER
            endcase
            
        end
    end

endmodule



