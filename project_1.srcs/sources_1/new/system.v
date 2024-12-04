`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2021 09:31:37 PM
// Design Name: 
// Module Name: system
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


module system(
    inout wire [7:0] JB,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    input clk,
    input [7:0] sw,
    input btnC
    );
    assign RsTx = JB[0];
    assign RsRx = JB[1];
    
    // Clock
    wire targetClk;
    wire [18:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        halfClock fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    halfClock fdivTarget(targetClk,tclk[18]);    
    
    // display
    wire [7:0] num0,num1,num2,num3;
    assign dp = 1;
    quadSevenSeg q7s(seg,an,num0,num1,num2,num3,targetClk);
    
    //uart
    uart uart(clk,RsRx,RsTx,num0,btnC,sw);
    
endmodule