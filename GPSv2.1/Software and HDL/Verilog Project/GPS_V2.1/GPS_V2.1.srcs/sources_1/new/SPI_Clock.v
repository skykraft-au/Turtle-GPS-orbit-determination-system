`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     17.11.2026 12:00:00
// Design Name: 
// Module Name:     SPI_Clock
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Creates a clock for all SPI communication according to specifications
// 
// Dependencies:    None
// 
// Revision:
// Revision 1.00 - Turtle GPS v2.1
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI_Clock(
        input wire      clk,
        output wire     SPI_Tick
    );
    

    //--------------------------------------------------------------------------------------------------
    //  Registers
    //--------------------------------------------------------------------------------------------------

    reg         SPI_Tick_reg    = 0;
    reg [7:0]   counter         = 0;    //Max value of 256
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin   //3 Part if statement gives a SPI Speed of 0.5 MHz at 50% duty cycle
        if ((counter < 199) && (counter >= 99)) 
        begin
            SPI_Tick_reg    <= 1;
            counter         <= counter + 1;
        end 
        else if (counter == 199) 
        begin
            SPI_Tick_reg    <= 1;
            counter         <= 0;
        end 
        else 
        begin
            SPI_Tick_reg    <= 0;
            counter         <= counter + 1;
        end
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign SPI_Tick         = SPI_Tick_reg;
    
    
endmodule
