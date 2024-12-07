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
    inout wire [1:0] JB,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output [11:0] rgb,
    output hsync, vsync,
    input clk,
    input [7:0] sw,
    input btnC,
    input btnU
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
    wire [3:0] num0, num1, num2, num3;
    wire an0, an1, an2, an3;
    assign {num1, num0} = sw;
    assign {num3, num2} = ascii;
    assign an = {an3, an2, an1, an0};
    assign dp = 1;
    quadSevenSeg q7s(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,targetClk);

    // signals
    wire [9:0] w_x;
    wire [9:0] w_y;
    wire w_vid_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [7:0] ascii;
    wire char_received;
    // instantiate vga controller
    vga_controller vga(.clk(clk), .reset(btnU), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), 
                       .x(w_x), .y(w_y));
    
    // instantiate text generation circuit
    terminal tsg(.clk(clk), .reset(btnU),.video_on(w_vid_on), .set(char_received),
                        .ascii(ascii), .x(w_x), .y(w_y), .rgb(rgb_next));
    
    //uart
    uart uart(clk,RsRx,RsTx,ascii,char_received,btnC,sw);
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
endmodule