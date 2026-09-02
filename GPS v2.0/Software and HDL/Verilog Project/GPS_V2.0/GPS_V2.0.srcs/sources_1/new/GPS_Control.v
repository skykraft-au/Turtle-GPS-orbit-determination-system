`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 12:08:33
// Design Name: 
// Module Name:     GPS_Control
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Connects buttons on wires to begin wires as desired
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GPS_Control #(
        parameter   [11:0]  period_Transmission     = 0, //Placeholder parameters to be overwritten
        parameter   [31:0]  sample_time             = 0,
        parameter   [7:0]   data_Transmission       = 0,
        parameter   [7:0]   period_Sample           = 0
    )
    (
        input wire          clk,
        input wire          I0,
        output wire         MAX_CONFIG_BEGIN,
        output wire         LORA_CONFIG_BEGIN,
        output wire         SAMPLE_BEGIN,
        output wire         reset
    );


    //--------------------------------------------------------------------------------------------------
    //  Registers and wires
    //--------------------------------------------------------------------------------------------------

    reg         MAX_CONFIG_BEGIN_reg        = 0;
    reg         LORA_CONFIG_BEGIN_reg       = 0;
    reg         SAMPLE_BEGIN_reg            = 0;
    reg         reset_reg                   = 0;

    reg         config_run                  = 0;
    reg [40:0]  delay_counter               = 0;

    reg         random_number_request_reg   = 0;

    wire        random_number_request;
    wire [7:0]  random_number;

    //--------------------------------------------------------------------------------------------------
    //  Instantiate the Pseudo-random number generator
    //--------------------------------------------------------------------------------------------------

    Pseudo_Random_Number_Generator PRNG (
        .clk(clk),
        .I0(I0),
        .random_number_request(random_number_request),
        .random_number(random_number)
    );

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic and Control of Sequence including delay
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin
        if (config_run == 0)
        begin
            if (delay_counter < 199_999_999)
            begin
                delay_counter               <= delay_counter + 1;

                MAX_CONFIG_BEGIN_reg        <= 1;
                LORA_CONFIG_BEGIN_reg       <= 1;
                reset_reg                   <= 0;
                SAMPLE_BEGIN_reg            <= 0;
            end
            else if (delay_counter < 249_999_999)
            begin
                delay_counter           <= delay_counter + 1;

                MAX_CONFIG_BEGIN_reg        <= 0;
                LORA_CONFIG_BEGIN_reg       <= 0;
                reset_reg                   <= 0;
                SAMPLE_BEGIN_reg            <= 0;

                random_number_request_reg   <= 1;
            end
            else if (delay_counter < 259_999_999)
            begin
                delay_counter               <= delay_counter + 1;

                random_number_request_reg   <= 0;
            end
            else if (delay_counter < (269_999_999 + (100_000_000*random_number)))
            begin
                delay_counter               <= delay_counter + 1;
            end
            else
            begin
                config_run                  <= 1;
                delay_counter               <= 0;
            end
        end
        else
        begin
            if (delay_counter < 8_999)
            begin
                delay_counter               <= delay_counter + 1;
            end
            else if (delay_counter < sample_time + (period_Sample+500)*100_000)
            begin
                delay_counter               <= delay_counter + 1;

                reset_reg                   <= 0;
                SAMPLE_BEGIN_reg            <= 1;
            end
            else if (delay_counter < sample_time + (period_Sample+500)*100_000 + 100_000_000*period_Transmission + 80_000_000*data_Transmission)
            begin
                delay_counter               <= delay_counter + 1;

                reset_reg                   <= 0;
                SAMPLE_BEGIN_reg            <= 0;
            end
            else
            begin
                delay_counter               <= 0;

                reset_reg                   <= 1;
            end
        end
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign MAX_CONFIG_BEGIN         = MAX_CONFIG_BEGIN_reg;
    assign LORA_CONFIG_BEGIN        = LORA_CONFIG_BEGIN_reg;
    assign SAMPLE_BEGIN             = SAMPLE_BEGIN_reg;
    assign reset                    = reset_reg;

    assign random_number_request    = random_number_request_reg;
    

endmodule
