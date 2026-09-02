`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 14:57:42
// Design Name: 
// Module Name:     LORA_tx
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     Transmission control module for the LORA chip
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LORA_tx(
        input wire          clk,
        input wire          SPI_Tick,
        input wire          tx_start,
        input wire [7:0]    packet_byte,
        output wire         tx_initialised,
        output wire         CSN,
        output wire         SDATA,
        output wire         SCLK_en_tx,
        output wire         tx_done
    );
    
    //--------------------------------------------------------------------------------------------------
    //  Parameters
    //--------------------------------------------------------------------------------------------------

    parameter   delay = 50;


    //--------------------------------------------------------------------------------------------------
    //  States
    //--------------------------------------------------------------------------------------------------

    parameter [2:0] idle        = 3'b000,   //Holds and initialises before moving to start //ALSO CHANGE TO ENUM
                    setup_start = 3'b001,   //Setup prior to transmission
                    setup_data  = 3'b010,   //Setup Data and cycle back
                    fifo_start  = 3'b011,   //Write/Read bit and Address for fifo
                    fifo_data   = 3'b100,   //Data bits then move to stop for data
                    mode_start  = 3'b101,
                    mode_data   = 3'b110,
                    stop        = 3'b111;   //Stop bits
                    

    //--------------------------------------------------------------------------------------------------
    //  Registers and Variables
    //--------------------------------------------------------------------------------------------------

    reg [2:0]   state                           = idle, 
                state_next;
    reg [6:0]   fifo_address                    = 7'h00, 
                mode_address                    = 7'h01;    //Addresses
    reg [7:0]   data_bits                       = 8'h00,
                data_bits_next;                             //data_bits
    reg [7:0]   tx_mode_data                    = 8'h8B;    //Tx Mode
    
    reg [511:0] packet_reg                      = 0;
    
    reg [6:0]   setup_address_memory    [0:10];
    reg [7:0]   setup_data_memory       [0:10];
    reg [6:0]   current_address;
    reg [7:0]   current_data;
    
    reg         CSN_reg                         = 1, 
                CSN_reg_next;
    reg         SDATA_reg                       = 0, 
                SDATA_reg_next;
    reg         SCLK_en                         = 0, 
                SCLK_en_next;
    
    reg [13:0]  bit                             = 0, 
                bit_next;
    reg [7:0]   byte_index                      = 0, 
                byte_index_next;
    reg [7:0]   packet_reg_transfer_byte_index  = 0;
                
    reg         tx_done_reg                     = 1;
    reg         tx_initialised_reg              = 1;
    
    integer i;
    

    //--------------------------------------------------------------------------------------------------
    //  Initialisation
    //--------------------------------------------------------------------------------------------------

    initial 
    begin
        //Initialises values for setup
        setup_address_memory[0] = 7'h20;
        setup_address_memory[1] = 7'h21; 
        setup_address_memory[2] = 7'h24;
        setup_address_memory[3] = 7'h40;
        setup_address_memory[4] = 7'h12;
        setup_address_memory[5] = 7'h22;
        setup_address_memory[6] = 7'h0E;
        setup_address_memory[7] = 7'h0D;
        
        setup_data_memory[0]    = 8'h00;    //Preable Length
        setup_data_memory[1]    = 8'h10;    //Preable Length
        setup_data_memory[2]    = 8'h00;
        setup_data_memory[3]    = 8'h40;    //Datapins
        setup_data_memory[4]    = 8'hFF;    //IRQ
        setup_data_memory[5]    = 8'h40;    //Payload Length
        setup_data_memory[6]    = 8'h00;
        setup_data_memory[7]    = 8'h00;
        
        //Assigns default values to next-state variables
        state_next              <= idle;
        
        CSN_reg_next            <= 1;
        SDATA_reg_next          <= 0;
        SCLK_en_next            <= 0;
        
        bit_next                <= 0;
        byte_index_next         <= 0;
        data_bits_next          <= 8'h00;
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin
        state       <= state_next;
        data_bits   <= data_bits_next;
                
        CSN_reg     <= CSN_reg_next;
        SDATA_reg   <= SDATA_reg_next;
        SCLK_en     <= SCLK_en_next;
                
        byte_index  <= byte_index_next;
        bit         <= bit_next;
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic with Statemachine
    //--------------------------------------------------------------------------------------------------

    always @(negedge SPI_Tick) 
    begin
        //Assigns default values to next-state variables
        state_next                                  <= state;
        
        CSN_reg_next                                <= CSN_reg;
        SDATA_reg_next                              <= SDATA_reg;
        SCLK_en_next                                <= SCLK_en;
        
        byte_index_next                             <= byte_index;
        bit_next                                    <= bit;
        data_bits_next                              <= data_bits;
    
        //Statemachine
        case(state)
            idle: 
            begin
                CSN_reg_next                        <= 1;           //Sets to 1
                SCLK_en_next                        <= 1;
                SDATA_reg_next                      <= 0;           //Sets to 0 state

                if (tx_start == 1) 
                begin
                    //Transfer of Data
                    if (packet_reg_transfer_byte_index < 2)
                    begin
                        tx_initialised_reg              <= 0;

                        packet_reg_transfer_byte_index  <= packet_reg_transfer_byte_index + 1;
                    end
                    else if (packet_reg_transfer_byte_index < 66)
                    begin
                        packet_reg                      <= {packet_byte, packet_reg[511:8]};

                        packet_reg_transfer_byte_index  <= packet_reg_transfer_byte_index + 1;
                    end
                    else
                    begin
                        bit_next                        <= 0;
                        tx_initialised_reg              <= 1;
                        state_next                      <= setup_start;
                    end
                end
            end
            
            setup_start: 
            begin
                //Actual Setup
                CSN_reg_next                        <= 0;
                SCLK_en_next                        <= 0;

                tx_done_reg                         <= 0;
                packet_reg_transfer_byte_index      <= 0;
                    
                current_address                     <= setup_address_memory[byte_index];
                current_data                        <= setup_data_memory[byte_index];
                
                if (bit < 1) 
                begin
                    SDATA_reg_next                  <= 1;           //Write bit
                    bit_next                        <= bit + 1;
                end 
                else if (bit < 7)
                begin
                    SDATA_reg_next                  <= current_address[7 - bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    SDATA_reg_next                  <= current_address[0];
                    bit_next                        <= 0;
                    state_next                      <= setup_data;
                end
            end
            
            setup_data: 
            begin
                if (bit < 7) 
                begin
                    SDATA_reg_next                  <= current_data[7-bit];
                    bit_next                        <= bit + 1;
                end 
                else if (bit < 8) 
                begin
                    SDATA_reg_next                  <= current_data[0];
                    bit_next                        <= bit + 1;
                end 
                else if (bit < (9 + delay)) 
                begin
                    SDATA_reg_next                  <= 0;
                    SCLK_en_next                    <= 1;
                    CSN_reg_next                    <= 1;
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    bit_next                        <= 0;   
                    if (byte_index < 7) 
                    begin
                        state_next                  <= setup_start;    
                        byte_index_next             <= byte_index + 1; 
                    end 
                    else 
                    begin
                        byte_index_next             <= 0;
                        state_next                  <= fifo_start;
                    end
                end
            end
            
            fifo_start: 
            begin
                SCLK_en_next                        <= 0;
                CSN_reg_next                        <= 0;
                if (bit < 1) 
                begin
                    SDATA_reg_next                  <= 1;           //Write bit
                    bit_next                        <= bit + 1;
                end 
                else if (bit < 7) 
                begin
                    SDATA_reg_next                  <= fifo_address[7-bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    data_bits_next                  <= packet_reg[511:504];
                    packet_reg                      <= {packet_reg[503:0], 8'h0};

                    SDATA_reg_next                  <= fifo_address[0];
                    bit_next                        <= 0;
                    byte_index_next                 <= 0;
                    state_next                      <= fifo_data;
                end
            end
            
            fifo_data: 
            begin
                if (bit < 7) 
                begin
                    SDATA_reg_next                  <= data_bits[7-bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    SDATA_reg_next                  <= data_bits[0];
                    bit_next                        <= 0;
                    if (byte_index < 63) 
                    begin
                        byte_index_next             <= byte_index + 1;
                        data_bits_next              <= packet_reg[511:504];
                        packet_reg                  <= {packet_reg[503:0], 8'h0};
                    end 
                    else 
                    begin
                        byte_index_next             <= 0;
                        state_next                  <= mode_start;
                    end
                end
            end
            
            mode_start: 
            begin
                if (bit < 1) 
                begin
                    SCLK_en_next                    <= 1;
                    bit_next                        <= bit + 1;
                end 
                else if (bit < (3 + delay)) 
                begin
                    CSN_reg_next                    <= 1;           //Delays CSN high
                    bit_next                        <= bit + 1;
                end 
                else if (bit < (4 + delay)) 
                begin
                    CSN_reg_next                    <= 0;
                    SCLK_en_next                    <= 0;
                    SDATA_reg_next                  <= 1;           //Write bit
                    bit_next                        <= bit + 1;
                end 
                else if (bit < (10 + delay)) 
                begin
                    SDATA_reg_next                  <= mode_address[(10 + delay) - bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    SDATA_reg_next                  <= mode_address[0];
                    bit_next                        <= 0;
                    state_next                      <= mode_data;
                end
            end
            
            mode_data: 
            begin
                if (bit < 7) 
                begin
                    SDATA_reg_next                  <= tx_mode_data[7-bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    SDATA_reg_next                  <= tx_mode_data[0];
                    bit_next                        <= 0;
                    state_next                      <= stop;                 
                end
            end
            
            stop: 
            begin
                SCLK_en_next                        <= 1;
                SDATA_reg_next                      <= 0;
                if (bit == 1) 
                begin
                    CSN_reg_next                    <= 1;           //Delays CSN high
                    state_next                      <= idle;
                    tx_done_reg                     <= 1;
                end 
                else 
                begin
                    bit_next                        <= bit + 1;     //Increments bit register for delay of CSN
                end
            end
        endcase
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------

    assign LoRa_Reset       = 1;
    assign CSN              = CSN_reg;
    assign SDATA            = SDATA_reg;
    assign SCLK_en_tx       = SCLK_en;

    assign tx_done          = tx_done_reg;
    assign tx_initialised   = tx_initialised_reg;
    

endmodule
