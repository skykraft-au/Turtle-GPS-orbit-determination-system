`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 12:02:27
// Design Name: 
// Module Name:     GPS_Top
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Connects and instantiates modules
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GPS_Top(
        input wire          clk,
        input wire          I0,       
        input wire          I1,      
        input wire          Q0,       
        input wire          Q1,         
        input wire          ADC_CLK,        //ADC Clock Output from MAX2771 for Synchronisation
        input wire          DIO0,           //DIO pin from LoRa to indicate tx_done state
        input wire          LORA_MISO,
        output wire         LORA_SDATA,
        output wire         LORA_SCLK,
        output wire         LORA_CSN,
        output wire         LORA_RESET,     //Line to enable LoRa
        output wire         MAX_SDATA,
        output wire         MAX_SCLK,
        output wire         MAX_CSN,
        output wire         LED
    );
    
    //--------------------------------------------------------------------------------------------------
    //  Parameters
    //--------------------------------------------------------------------------------------------------

    //GPS Config Register
    //Bits [31,20] = Period between Full Transmission (Seconds)
    //Bits [19,12] = Data per Full Transmission (Kilobits), one IQ sample is treated as one bit
    //Bits [11,4] = Period between Samples (Milliseconds)
    //Bits [3,0] = Data per Sample (Kilobits, Set to 0 for continous transmission)
    parameter  [31:0]  GPS_Config          = 32'h00280000; //Continuous sample with 2 seconds between transmission of 128 kbits of data

    parameter   [11:0]  period_Transmission = GPS_Config[31:20];
    parameter   [7:0]   data_Transmission   = GPS_Config[19:12];
    parameter   [7:0]   period_Sample       = GPS_Config[11:4];
    parameter   [3:0]   data_Sample         = GPS_Config[3:0];
    parameter   [31:0]  sample_time         = (data_Sample == 0)?     
                                                (data_Transmission*2*6250) :
                                                ((data_Transmission*2*6250)+(period_Sample*((data_Transmission*2/data_Sample)-1)*100000));

    //--------------------------------------------------------------------------------------------------
    //  Wires
    //--------------------------------------------------------------------------------------------------

    wire MAX_CONFIG_BEGIN;
    wire LORA_CONFIG_BEGIN;
    wire reset;
    wire SAMPLE_BEGIN; 
    
    wire SPI_Tick;
    wire [1:0] Data;
    
    wire ADC_Tick;
    
    wire tx_start;
    wire tx_done;
    wire tx_initialised;
    wire [7:0] packet_byte;

    //--------------------------------------------------------------------------------------------------
    //  Instantiations
    //--------------------------------------------------------------------------------------------------

    GPS_Control #(
        .period_Transmission(period_Transmission),
        .data_Transmission(data_Transmission),
        .sample_time(sample_time),
        .period_Sample(period_Sample)
    )GPS_CONTROL (
        .clk(clk),
        .I0(I0),
        .MAX_CONFIG_BEGIN(MAX_CONFIG_BEGIN),
        .LORA_CONFIG_BEGIN(LORA_CONFIG_BEGIN),
        .SAMPLE_BEGIN(SAMPLE_BEGIN),
        .reset(reset)
    );
    
    SPI_Clock SPI_CLOCK (
        .clk(clk),
        .SPI_Tick(SPI_Tick)
    );
    
    MAX_Driver MAX_DRIVER (
        .clk(clk),
        .MAX_CONFIG_BEGIN(MAX_CONFIG_BEGIN),
        .SPI_Tick(SPI_Tick),
        .MAX_SDATA(MAX_SDATA),
        .MAX_SCLK(MAX_SCLK),
        .MAX_CSN(MAX_CSN),
        .reset(reset)
    );

    LORA_Driver LORA_DRIVER (
        .clk(clk),
        .LORA_CONFIG_BEGIN(LORA_CONFIG_BEGIN),
        .SPI_Tick(SPI_Tick),
        .tx_start(tx_start),
        .packet_byte(packet_byte),
        .tx_initialised(tx_initialised),
        .LORA_MISO(LORA_MISO),
        .LORA_SDATA(LORA_SDATA),
        .LORA_SCLK(LORA_SCLK),
        .LORA_CSN(LORA_CSN),
        .LORA_RESET(LORA_RESET),
        .tx_done(tx_done),
        .reset(reset)
    );
    
    DATA_Handler #(
        .data_Transmission(data_Transmission),
        .period_Sample(period_Sample),
        .data_Sample(data_Sample)
    ) DATA_HANDLER (
        .clk(clk),
        .SPI_Tick(SPI_Tick),
        .ADC_CLK(ADC_CLK),
        .ADC_Tick(ADC_Tick),
        .tx_done(tx_done),
        .Data(Data),
        .packet_byte(packet_byte),
        .tx_initialised(tx_initialised),
        .tx_start(tx_start),
        .SAMPLE_BEGIN(SAMPLE_BEGIN),
        .reset(reset)
    );
    
    DATA_PROCESSING DATA_PROCESSOR (
        .ADC_Tick(ADC_Tick),
        .Data(Data),
        .I0(I0),
        .I1(I1),
        .Q0(Q0),
        .Q1(Q1)
    );
    
    assign LED = SAMPLE_BEGIN;

endmodule
