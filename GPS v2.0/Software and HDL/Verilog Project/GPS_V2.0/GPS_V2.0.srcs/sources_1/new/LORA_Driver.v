`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 14:33:14
// Design Name: 
// Module Name:     LORA_Driver
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Top module for LORA control through configuration and transmission
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LORA_Driver(
        input wire          clk,
        input wire          LORA_CONFIG_BEGIN,
        input wire          reset,
        input wire          SPI_Tick,
        input wire          tx_start,
        input wire [7:0]    packet_byte,
        input wire          LORA_MISO,
        output wire         tx_initialised,
        output wire         LORA_SDATA,
        output wire         LORA_SCLK,
        output wire         LORA_CSN,
        output wire         LORA_RESET,
        output wire         tx_done
    );
    

    //--------------------------------------------------------------------------------------------------
    //  Wires
    //--------------------------------------------------------------------------------------------------

    wire    SDATA_config;
    wire    SCLK_en_config;
    wire    CSN_config;
    
    wire    SDATA_tx;
    wire    SCLK_en_tx;
    wire    CSN_tx;
    

    //--------------------------------------------------------------------------------------------------
    //  Instantiation
    //--------------------------------------------------------------------------------------------------

    LORA_Config LORA_CONFIG (
        .clk(clk),
        .SPI_Tick(SPI_Tick),
        .LORA_CONFIG_BEGIN(LORA_CONFIG_BEGIN),
        .CSN(CSN_config),
        .SDATA(SDATA_config),
        .SCLK_en_config(SCLK_en_config),
        .reset(reset)
    );
    
    LORA_tx LORA_TX (
        .clk(clk),
        .SPI_Tick(SPI_Tick),
        .tx_start(tx_start),
        .packet_byte(packet_byte),
        .tx_initialised(tx_initialised),
        .CSN(CSN_tx),
        .SDATA(SDATA_tx),
        .SCLK_en_tx(SCLK_en_tx),
        .tx_done(tx_done)
    );
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign LORA_SCLK    = ((!SCLK_en_tx)|(!SCLK_en_config))? SPI_Tick:1'b0;
    assign LORA_CSN     = !((!CSN_tx) | (!CSN_config));
    assign LORA_SDATA   = ((SDATA_tx) | (SDATA_config));
    assign LORA_RESET   = 1;


endmodule
