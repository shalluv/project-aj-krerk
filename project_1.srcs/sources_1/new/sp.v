`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 09:23:09 AM
// Design Name: 
// Module Name: sp
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


module sp(
    output out,
    input d,
    input clk
    );
    reg [1:0] state;
    reg out;
    initial begin
        out = 0;
        state = 2'b00;
    end
    always @(state) begin
        if (state == 2'b01) begin
            out = 1;
        end
        else begin
            out = 0;
        end
    end
    always @(posedge clk) begin
        if (d) begin
            if (state == 2'b00) begin
                state = 2'b01;
            end
            else if (state == 2'b01) begin
                state = 2'b10;
            end
       end
       else begin
            state = 2'b00;
       end
    end
endmodule