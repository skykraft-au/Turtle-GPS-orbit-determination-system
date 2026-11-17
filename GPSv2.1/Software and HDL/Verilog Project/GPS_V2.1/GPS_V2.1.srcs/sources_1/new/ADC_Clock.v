`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     17.11.2026 12:00:00
// Design Name: 
// Module Name:     ADC_Clock
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Creates a digital clock signal from the ADC_CLK input wire using sequential logic
// 
// Dependencies:    None
// 
// Revision:
// Revision 1.00 - Turtle GPS v2.1
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ADC_Clock(
        input wire      clk,
        input wire      ADC_CLK,
        output wire     ADC_Tick
    );
    
    
    //--------------------------------------------------------------------------------------------------
    //  Registers
    //--------------------------------------------------------------------------------------------------

    reg ADC_Tick_reg;
    reg changed = 0;
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin
        if ((ADC_CLK == 1) && (changed == 0)) 
        begin
            changed         <= 1;
            ADC_Tick_reg    <= 1;
        end 
        else 
        begin
            if (ADC_CLK == 0) 
            begin
                changed     <= 0;
            end
            
            ADC_Tick_reg    <= 0;
        end
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign ADC_Tick = ADC_Tick_reg;
    

endmodule
