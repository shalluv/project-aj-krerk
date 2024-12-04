`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 10:05:01 AM
// Design Name: 
// Module Name: halfClock
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


module halfClock(
    output clkDiv,
    input clk
    );
    reg clkDiv;
    initial begin
        clkDiv = 0;
    end;
    always @(posedge clk)
    begin
        clkDiv = ~clkDiv;
    end
endmodule