`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 14:55:20
// Design Name: 
// Module Name:     LORA_Config
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Configures the LoRa module upon trigger
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LORA_Config(
        input wire      clk,
        input wire      SPI_Tick,
        input wire      LORA_CONFIG_BEGIN,   //Trigger for Module
        input wire      reset,
        output wire     CSN,
        output wire     SDATA,
        output wire     SCLK_en_config
    );
    

    //--------------------------------------------------------------------------------------------------
    //  States
    //--------------------------------------------------------------------------------------------------

    parameter [1:0]     idle    = 2'b00,    //Holds and initialises before moving to start
                        start   = 2'b01,    //Write bit and Address
                        data    = 2'b10,    //Data bits then move to stop
                        stop    = 2'b11;    //Stop bits
                    
    
    //--------------------------------------------------------------------------------------------------
    //  Registers and Variables
    //--------------------------------------------------------------------------------------------------

    reg [1:0]   state               = idle, 
                state_next;
    reg [6:0]   address, 
                address_next;
    reg [7:0]   data_bits, 
                data_bits_next;
    
    reg [6:0]   address_memory    [0:26];
    reg [7:0]   data_memory       [0:26];
    
    reg         CSN_reg             = 1,
                CSN_reg_next;
    reg         SDATA_reg           = 0, 
                SDATA_reg_next;
    reg         SCLK_en             = 0, 
                SCLK_en_next;
    
    reg [12:0]  bit                 = 0,
                bit_next;
    reg [7:0]   LoRa_register_index = 0, 
                LoRa_register_index_next;

    integer i;
    

    //--------------------------------------------------------------------------------------------------
    //  Initialisation
    //--------------------------------------------------------------------------------------------------

    initial 
    begin
        address_memory[0]   = 7'h01;
        address_memory[1]   = 7'h24;
        address_memory[2]   = 7'h01;
        address_memory[3]   = 7'h01;
        address_memory[4]   = 7'h01;
        address_memory[5]   = 7'h06;
        address_memory[6]   = 7'h07;
        address_memory[7]   = 7'h08;
        address_memory[8]   = 7'h09;
        address_memory[9]   = 7'h4D;        // Pa boost
        address_memory[10]  = 7'h0B;
        address_memory[11]  = 7'h0C;
        address_memory[12]  = 7'h0D;
        address_memory[13]  = 7'h0E;
        address_memory[14]  = 7'h1D;
        address_memory[15]  = 7'h1E;
        address_memory[16]  = 7'h20;
        address_memory[17]  = 7'h21;
        address_memory[18]  = 7'h22;
        address_memory[19]  = 7'h24;
        address_memory[20]  = 7'h26;
        address_memory[21]  = 7'h31;
        address_memory[22]  = 7'h37;
        address_memory[23]  = 7'h39;
        address_memory[24]  = 7'h3B;
        address_memory[25]  = 7'h40;
        address_memory[26]  = 7'h12;        //IRQ
        
        data_memory[0]      = 8'h09;
        data_memory[1]      = 8'h00;        //This configures to LoRa and low freq
        data_memory[2]      = 8'h08;
        data_memory[3]      = 8'h88;
        data_memory[4]      = 8'h89;
        data_memory[5]      = 8'h6C;        //Carrier frequency of 433 MHz
        data_memory[6]      = 8'h40;        //Carrier frequency
        data_memory[7]      = 8'h00;        //Carrier frequency
        data_memory[8]      = 8'hFF;        //Sets max power
        data_memory[9]      = 8'h87;        // High power mode, i.e. +20 dBm
        data_memory[10]     = 8'h36;        //Overload current protection to Imax = 190 mA
        data_memory[11]     = 8'h23;        //LNA
        data_memory[12]     = 8'h00;        //Fifo Base Address
        data_memory[13]     = 8'h00;        //Fifo Pointer Address
        data_memory[14]     = 8'h96;        //Bandwidth 500kHz, Error Coding, and Header mode 
        //data_memory[15]     = 8'h84;        //Spreading Factor (using 8) and TX mode 
        //data_memory[15]     = 8'h94;        //Spreading Factor (using 9) and TX mode 
        data_memory[15]     = 8'hA4;        //Spreading Factor (using 10) and TX mode 
        //data_memory[15]     = 8'hB4;        //Spreading Factor (using 11) and TX mode 
        //data_memory[15]     = 8'hC4;        //Spreading Factor (using 12) and TX mode 
        data_memory[16]     = 8'h00;        //Preamble Length
        data_memory[17]     = 8'h10;        //Preamble Length
        data_memory[18]     = 8'h40;        //Payload Length of 64 bytes
        data_memory[19]     = 8'h00;        //Symbol Period  
        data_memory[20]     = 8'h04;        // RegModemConfig3
        data_memory[21]     = 8'hC3;        // Detection Optimise
        data_memory[22]     = 8'h0A;
        data_memory[23]     = 8'h12;        //Sync Word
        data_memory[24]     = 8'h1D;
        data_memory[25]     = 8'h40;        //Data pin mapping
        data_memory[26]     = 8'hFF;        //Clear IRQ

        //The above pin mapping gives:  DIO0 = TxDone, 
        //                              DIO1 = CadDetected, 
        //                              DIO2 = FhssChangeChannel, 
        //                              DIO3 = PayloadCrcError, 
        //                              DIO4 = PllLock, 
        //                              DIO5 = ModeReady
        
        
        //Initialises variables with default values
        state_next                  <= idle;
        
        CSN_reg_next                <= 1;
        SDATA_reg_next              <= 0;
        SCLK_en_next                <= 0;
        
        bit_next                    <= 0;
        LoRa_register_index_next    <= 0;
        
        address_next                <= 7'h01;
        data_bits_next              <= 8'h09;
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Update Logic
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk, posedge reset) 
    begin
        if (reset == 1)
        begin
            state                   <= idle;
            address                 <= address_memory[0];
            data_bits               <= data_memory[0];
                
            CSN_reg                 <= 1;
            SDATA_reg               <= 0;
            SCLK_en                 <= 0;
                
            bit                     <= 0;
            LoRa_register_index     <= 0;
        end
        else
        begin
            state                   <= state_next;
            address                 <= address_next;
            data_bits               <= data_bits_next;
                
            CSN_reg                 <= CSN_reg_next;
            SDATA_reg               <= SDATA_reg_next;
            SCLK_en                 <= SCLK_en_next;
                
            bit                     <= bit_next;
            LoRa_register_index     <= LoRa_register_index_next;
        end
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic with Statemachine
    //--------------------------------------------------------------------------------------------------

    always @(negedge SPI_Tick) 
    begin
        //Assigns default values to next-state variables
        state_next                  <= state;
        
        CSN_reg_next                <= CSN_reg;
        SDATA_reg_next              <= SDATA_reg;
        SCLK_en_next                <= SCLK_en;
        
        bit_next                    <= bit;
        LoRa_register_index_next    <= LoRa_register_index;
        
        //Assigns default values according to step in iteration
        address_next                <= address_memory[LoRa_register_index];
        data_bits_next              <= data_memory[LoRa_register_index];
    
        //Statemachine
        case(state)
            idle: 
            begin
                CSN_reg_next        <= 1;   //Sets to 1
                SCLK_en_next        <= 1;
                SDATA_reg_next      <= 0;   //Sets to high-Z state
                if (LORA_CONFIG_BEGIN == 1) 
                begin
                    if (bit < 800) 
                    begin
                        bit_next    <= bit + 1;
                    end 
                    else 
                    begin
                        bit_next    <= 0;
                        state_next  <= start;
                    end
                end
            end
            
            start: 
            begin
                CSN_reg_next        <= 0; //Sets CSN Low to begin SPI transfer
                SCLK_en_next        <= 0;
                if (bit < 1) 
                begin //Write bit
                    SDATA_reg_next  <= 1;
                    bit_next        <= bit + 1;
                end 
                else if (bit < 7) 
                begin //Address bits
                    SDATA_reg_next  <= address[7-bit];
                    bit_next        <= bit + 1;
                end 
                else 
                begin //Swaps to data state and resets bit variable
                    SDATA_reg_next  <= address[0];
                    bit_next        <= 0;
                    state_next      <= data;
                end
            end
            
            data: 
            begin
                if (bit < 7) 
                begin   //Data bits
                    SDATA_reg_next  <= data_bits[7 - bit];
                    bit_next        <= bit + 1;
                end 
                else 
                begin   //Stop
                    SDATA_reg_next  <= data_bits[0];
                    bit_next        <= 0;
                    state_next      <= stop;
                end
            end
            
            stop: 
            begin
                SCLK_en_next        <= 1;
                SDATA_reg_next      <= 0;
                if (bit == 1) 
                begin
                    CSN_reg_next    <= 1;   //Triggers CSN_reg_next after a delay.
                
                    if (LoRa_register_index < 26) 
                    begin
                        LoRa_register_index_next    <= LoRa_register_index + 1;
                        state_next                  <= idle;
                        bit_next                    <= 0;
                    end
                end 
                else 
                begin
                    bit_next        <= bit + 1; //Increments bit for delay
                end
            end
        endcase
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign CSN              = CSN_reg;
    assign SDATA            = SDATA_reg;
    assign SCLK_en_config   = SCLK_en;
    

endmodule
