/* --To configure the OVA7670. It instantiates  
      cam_rom, rom_to_sccb and sccb modules .

   --
*/

module cam_config (
    input wire clk,
    input wire rst,

    input wire start_cam_config,
    output wire done_cam_config,

    output wire siod,
    output wire sioc,

    output wire one_phase_done // testbench purpose only
    
);

    /* wire between ram and ram_to_sccb*/
    wire [7:0]w_rom_addr; // address wire to rom
    wire [15:0]w_rom_data; //// data wire from rom


    /* wire between ram_to_sccb and sccb*/
    wire w_sccb_ready;
    wire w_sccb_start;
    wire [7:0]w_sccb_sub_address;
    wire [7:0]w_sccb_data;

   /* wire for testbench simulation only*/
   wire w_sccb_done;

cam_rom M1
    (   .i_clk(clk),
        .i_rstn(rst),
        .i_addr(w_rom_addr),
        .o_dout(w_rom_data)
    );



    rom_to_sccb M2
    (
        .clk(clk),
        .rst(rst),
        .sccb_ready(w_sccb_ready),
        .config_start(start_cam_config),
        .rom_data(w_rom_data),

        .rom_addr(w_rom_addr),
        .sccb_start(w_sccb_start),
        .sccb_sub_addr(w_sccb_sub_address), 
        .sccb_data(w_sccb_data), 
        .config_done(done_cam_config)
        
    );


    sccb M3
    (   .clk(clk),
        .sccb_start(w_sccb_start), // When SET we start to send data.
        .sub_address(w_sccb_sub_address),
        .data(w_sccb_data),

        .sccb_ready(w_sccb_ready), // set HIGH if ready to receive data.
        .one_phase_done(one_phase_done), // testbench purpose only
        .siod(siod),
        .sioc(sioc)

);


endmodule
