`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     28.01.2026 16:12:06
// Design Name: 
// Module Name:     DATA_PROCESSING
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Mixes data with a LO Frequency then Filters and Decimates
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DATA_PROCESSING(
        input wire          ADC_Tick,
        input wire          I0,
        input wire          I1,
        input wire          Q0,
        input wire          Q1,
        output wire [1:0]   Data
    );

    //--------------------------------------------------------------------------------------------------
    //  Wires and Registers
    //--------------------------------------------------------------------------------------------------

    wire [15:0]     DDS_data;
    wire            DDS_valid;

    wire [15:0]     FIR_data_in;
    wire [15:0]     FIR_data_out;

    wire            FIR_data_in_ready;

    wire            FIR_data_in_valid;
    wire            FIR_data_out_valid;

    reg [1:0]       data_out;
    reg [15:0]      FIR_data_in_reg;

    reg signed [2:0]      ar_reg;
    reg signed [2:0]      ai_reg;
    reg signed [1:0]      br_reg;
    reg signed [1:0]      bi_reg;

    wire signed [5:0]   r_in;
    wire signed [5:0]   i_in;

    //--------------------------------------------------------------------------------------------------
    //  Instantiations
    //--------------------------------------------------------------------------------------------------

    DDS_Gen DDS_GENERATOR (
        .aclk(ADC_Tick),
        .m_axis_data_tdata(DDS_data),
        .m_axis_data_tvalid(DDS_valid)
    );

    FIR_Filter FIR_FILTER (
        .aclk(ADC_Tick),
        .s_axis_data_tdata(FIR_data_in),
        .s_axis_data_tready(FIR_data_in_ready),
        .s_axis_data_tvalid(FIR_data_in_valid),
        .m_axis_data_tdata(FIR_data_out),
        .m_axis_data_tvalid(FIR_data_out_valid)
    );

    //--------------------------------------------------------------------------------------------------
    //  Main Clock Loop
    //--------------------------------------------------------------------------------------------------

    always @(negedge ADC_Tick)
    begin
        case({I1,I0})
            2'b00:
                ar_reg          <= -3'sd1;
            2'b01:
                ar_reg          <= -3'sd2;
            2'b10:
                ar_reg          <= 3'sd1;
            2'b11:
                ar_reg          <= 3'sd2;
        endcase

        case({Q1,Q0})
            2'b00:
                ai_reg          <= -3'sd1;
            2'b01:
                ai_reg          <= -3'sd2;
            2'b10:
                ai_reg          <= 3'sd1;
            2'b11:
                ai_reg          <= 3'sd2;
        endcase

        br_reg                  <= (DDS_data[15])?  2'sd1:-2'sd1;
        bi_reg                  <= (DDS_data[7])?   2'sd1:-2'sd1;

        if (FIR_data_in_ready == 1)
        begin
            FIR_data_in_reg     <= {2'b00, r_in, 2'b00, i_in};
        end

        if (FIR_data_out_valid == 1)
        begin
            data_out            <= {FIR_data_out[8], FIR_data_out[0]};
        end
    end

    //--------------------------------------------------------------------------------------------------
    //  Assignments
    //--------------------------------------------------------------------------------------------------

    assign FIR_data_in_valid    = DDS_valid;
    assign FIR_data_in          = FIR_data_in_reg;

    assign r_in                 = (ar_reg * br_reg) + (ai_reg * bi_reg);
    assign i_in                 = (ar_reg * bi_reg) - (ai_reg * br_reg);

    assign Data                 = data_out;

endmodule
