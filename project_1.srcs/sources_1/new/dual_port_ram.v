`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 12:10:21 PM
// Design Name: 
// Module Name: dual_port_ram
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


module dual_port_ram
    #(
        parameter DATA_SIZE = 8,
        parameter ADDR_SIZE = 13
    )
    (
    input clk,
    input we,
    input [ADDR_SIZE-1:0] addr_a, addr_b,
    input [DATA_SIZE-1:0] din_a,
    output [DATA_SIZE-1:0] dout_a, dout_b
    );
    
    // Infer the RAM as block ram
    (* ram_style = "block" *) reg [DATA_SIZE-1:0] ram [2**ADDR_SIZE-1:0];
    
    reg [ADDR_SIZE-1:0] addr_a_reg, addr_b_reg;
    
    reg [5:0] i;
    // body
    always @(posedge clk) begin
            if(we)      // write operation
                ram[addr_a] <= din_a;
            addr_a_reg <= addr_a;
            addr_b_reg <= addr_b;
    end
    
    // two read operations        
    assign dout_a = ram[addr_a_reg];
    assign dout_b = ram[addr_b_reg];
    
endmodule
