`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 12:05:31 PM
// Design Name: 
// Module Name: terminal
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


module terminal(
    input clk,
    input reset,
    input video_on,
    input set,
    input [7:0] ascii,
    input [9:0] x, y,
    output reg [11:0] rgb
    );

    // Signal declarations
    wire [10:0] rom_addr;
    wire [7:0] char_addr;
    wire [3:0] row_addr;
    wire [2:0] bit_addr;
    wire [7:0] font_word;
    wire ascii_bit;

    reg reset_done;
    reg [12:0] ram_reset_addr; // Address for RAM reset sequence
    reg [7:0] ram_reset_data; // Data to write during reset (always 0)
    parameter MAX_X = 80;   // 640 pixels / 8 data bits = 80
    parameter MAX_Y = 30;   // 480 pixels / 16 data rows = 30

    wire [11:0] addr_r, addr_w;
    wire [7:0] din, dout;

    wire we; // Write enable

    // Cursor tracking
    reg [6:0] cur_x_reg;
    reg [6:0] cur_x_next;
    reg [5:0] cur_y_reg;
    reg [5:0] cur_y_next;

    reg [9:0] pix_x1_reg, pix_y1_reg;
    reg [9:0] pix_x2_reg, pix_y2_reg;

    wire [11:0] text_rgb, text_rev_rgb;
    wire cursor_on;

    // States
    reg reset_in_progress; // Flag for reset sequence

    // Instantiate ROM and RAM
    ascii_rom a_rom(.clk(clk), .addr(rom_addr), .data(font_word));
    dual_port_ram dp_ram(
        .clk(clk),
        .we(we),
        .addr_a(addr_w),
        .addr_b(addr_r),
        .din_a(din),
        .dout_a(),
        .dout_b(dout)
    );

    initial begin
        cur_x_reg = 0;
        cur_y_reg = 2;
        cur_x_next = 0;
        cur_y_next = 2;
        ram_reset_addr = 0;
        reset_in_progress = 0;
    end

    // Registers
    always @(posedge clk or posedge reset) begin
        if (~reset_in_progress && reset) begin
            // Start RAM reset sequence
            reset_in_progress <= 1;
            ram_reset_addr <= 0;
            cur_x_reg <= 0;
            cur_y_reg <= 0;
        end else if (reset_in_progress) begin
            // Perform reset sequence
            if (ram_reset_addr < (MAX_X * MAX_Y)) begin
                ram_reset_addr <= ram_reset_addr + 1;
            end else begin
                reset_in_progress <= 0; // End reset
            end
        end else begin
            // Normal operation
            cur_x_reg <= cur_x_next;
            cur_y_reg <= cur_y_next;
            pix_x1_reg <= x;
            pix_x2_reg <= pix_x1_reg;
            pix_y1_reg <= y;
            pix_y2_reg <= pix_y1_reg;
        end
    end

    // RAM write enable and data
    assign addr_w = reset_in_progress ? ram_reset_addr : {cur_y_reg, cur_x_reg};
    assign we = reset_in_progress || set;
    assign din = reset_in_progress ? 8'b0 : ascii;

    // RAM read
    assign addr_r = {y[9:4], x[9:3]};
    assign char_addr = dout;

    // Font ROM
    assign row_addr = y[3:0];
    assign rom_addr = {char_addr, row_addr};

    // Use delayed coordinates to select a bit
    assign bit_addr = pix_x2_reg[2:0];
    assign ascii_bit = font_word[~bit_addr];

    // Object signals
    assign text_rgb = (ascii_bit) ? 12'h0F0 : 12'h555;
    assign cursor_rgb = 12'h000;
    
    reg last_move;
    always @(posedge clk) begin
            if (reset) begin
                cur_y_next <=2;
                cur_x_next <= 0;
            end
            else if (~last_move & set) begin
                if ((ascii == 7'h00a ||(cur_x_reg + 1 == MAX_X)) && (cur_y_reg + 1 != MAX_Y)) begin
                    cur_y_next <= cur_y_reg + 1;
                    cur_x_next <= 0;
                end
                else if (cur_x_reg + 1 != MAX_X) begin
                    cur_x_next <= cur_x_reg + 1;
                end
            end
            last_move = set;
    end

    // Cursor visibility
    assign cursor_on = ((pix_x2_reg[9:3] == cur_x_reg) && (pix_y2_reg[9:4] == cur_y_reg));

    // RGB multiplexing
    always @* begin
        if (~video_on)
            rgb = 12'h000; // Blank
        else if (cursor_on)
            rgb = cursor_rgb;
        else
            rgb = text_rgb;
    end
endmodule
