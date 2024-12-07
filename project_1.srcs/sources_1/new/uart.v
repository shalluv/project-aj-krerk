`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2021 09:59:35 PM
// Design Name: 
// Module Name: uart
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

module uart(
    input clk,
    input RsRx,
    output RsTx,
    output [7:0]data_in,
    output received,
    input btnC,
    input [7:0] sw
    );
    
    reg en, last_sen;
    wire [7:0] data_out;
    assign data_out = sw;
    wire [7:0] data_in;
    wire sent, baud;
    baudrate_gen baudrate_gen(clk, baud);
    uart_rx receiver(baud, RsRx, received, data_in);
    uart_tx transmitter(baud, data_out, en, sent, RsTx);
    
    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_sen & btnC) begin
            en = 1;
        end
        last_sen = btnC;
    end
    
endmodule