`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     03.08.2026 08:49:13
// Design Name: 
// Module Name:     Pseudo_Random_Number_Generator
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Generates a pseudo random number to delay the inital transmission sequence
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pseudo_Random_Number_Generator(
        input wire          clk,
        input wire          I0,
        input wire          random_number_request,
        output wire [7:0]   random_number
    );

    //--------------------------------------------------------------------------------------------------
    //  Parameters
    //--------------------------------------------------------------------------------------------------

    localparam [19:0] multiplier    = 20'd5;
    localparam [19:0] increment     = 20'd10;
    localparam [19:0] modulus_value = 20'd60;

    //--------------------------------------------------------------------------------------------------
    //  Registers
    //--------------------------------------------------------------------------------------------------

    reg [7:0]   random_number_reg;
    reg [19:0]  seed                = 20'b00000000000000000000;


    //--------------------------------------------------------------------------------------------------
    //  Main Clock Loop
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk)
    begin
        if (random_number_request == 1)
        begin
            seed                <= {seed[18:0], I0};
            random_number_reg   <= (multiplier * seed + increment) % modulus_value;
        end
    end


    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign random_number    = random_number_reg;


endmodule
