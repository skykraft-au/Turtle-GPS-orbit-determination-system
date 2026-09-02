`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     19.12.2025 11:51:31
// Design Name: 
// Module Name:     ADC_Clock
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Creates a clock signal from the ADC_CLK input wire
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
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
