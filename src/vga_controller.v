module vga_controller (
    input pclk,
    input rst,

    output [9:0]x, // Counts no. of pixels in each line
    output [9:0]y, // counts no. of lines on screen

    output video_on,
    output hsync,
    output vsync
);
    
    localparam HD = 640;  // horizontal display area
    localparam HFP = 16;  // horizontal front porch
    localparam HBP = 48;  // horizontal back porch
    localparam HR = 96;   // horizontal retrace area
    localparam HMAX = HD + HFP + HBP + HR - 1; // HMAX = 800

    localparam VD = 480;  // vertical display area
    localparam VFP = 10;  // vertical front porch
    localparam VBP = 33;  // vertical back porch
    localparam VR = 2;    // vertical retrace area
    localparam VMAX = VD + VFP + VBP + VR - 1; VMAX = 525


    reg [9:0]h_counter;
    reg [9:0]v_counter;
    
    // counter logic
    always @(posedge pclk or negedge rst) begin
        if (!rst) begin
            h_counter <= 0;
            v_counter <= 0;
        end

        else begin
            if (h_counter == HMAX) begin
                h_counter <= 0;
                if (v_counter == VMAX) begin
                    v_counter <= 0;
                end
                else v_counter = v_counter + 1;
            end

            else h_counter = h_counter + 1;
        end
    end

assign x = h_counter;
assign y = v_counter;

assign video_on = ((h_counter >= 0) && (h_counter < HD) && (v_counter >= 0) &&(v_counter < VD) );

assign hsync = ~((h_counter > HD + HFP - 1) && (h_counter < HD + HFP + HR));
assign vsync = ~((v_counter > VD + VFP - 1) && (v_counter < VD + VFP + VR));

endmodule