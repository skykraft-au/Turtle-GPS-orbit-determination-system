`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 14:04:24
// Design Name: 
// Module Name:     MAX_Driver
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     MAX2771 chip config driver
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MAX_Driver(
        input wire      clk,
        input wire      MAX_CONFIG_BEGIN,
        input wire      reset,
        input wire      SPI_Tick,
        output wire     MAX_SDATA,
        output wire     MAX_SCLK,
        output wire     MAX_CSN
    );
    

    //--------------------------------------------------------------------------------------------------
    //  States
    //--------------------------------------------------------------------------------------------------

    parameter [1:0] idle    = 2'b00,
                    start   = 2'b01,    //Start will initialise, address and select write
                    data    = 2'b10,    //This will transmit the data for the 32 bit register
                    stop    = 2'b11;    //Ends the transfer
    

    //--------------------------------------------------------------------------------------------------
    //  Registers
    //--------------------------------------------------------------------------------------------------

    reg [1:0]   state               = idle, 
                state_next;
    reg [3:0]   address, 
                address_next;               //This will cycle through the 10 address registers
    reg [31:0]  data_bits, 
                data_bits_next;             //This will cycle through the data for each address
    
    reg [3:0]   address_memory  [0:10];
    reg [31:0]  data_memory     [0:10];
    
    reg         CSN_reg             = 1, 
                CSN_reg_next;
    reg         SDATA_reg           = 1'bz, 
                SDATA_reg_next;
    reg         SCLK_en             = 0, 
                SCLK_en_next;
    
    reg [5:0]   bit                 = 0, 
                bit_next;
    reg [3:0]   max_register_index  = 0, 
                max_register_index_next;
    

    //--------------------------------------------------------------------------------------------------
    //  Initialisation
    //--------------------------------------------------------------------------------------------------

    initial 
    begin
        address_memory[0]       = 4'h0;
        address_memory[1]       = 4'h1;
        address_memory[2]       = 4'h2;
        address_memory[3]       = 4'h3;
        address_memory[4]       = 4'h4;
        address_memory[5]       = 4'h5;
        address_memory[6]       = 4'h6;
        address_memory[7]       = 4'h7;
        address_memory[8]       = 4'h8;
        address_memory[9]       = 4'h9;
        address_memory[10]      = 4'hA;
        
        data_memory[0]          = 32'hBEA41503;     // Centre at 4.29 MHz
        data_memory[1]          = 32'h28550288;     // Config Register 2
        data_memory[2]          = 32'h0EAFB1F4;
        data_memory[3]          = 32'h498C0008;     //REFDIV = *0.5  for 16 MHz
        data_memory[4]          = 32'h00B820F0;     //RDIV = 30 PLL      Integer Division Ratio = 1473 to give  1571.2 - real value is 1571.1
        data_memory[5]          = 32'h06B85270;     //PLL Fractional Division Ratio = 0.42
        data_memory[6]          = 32'h08000000;
        data_memory[7]          = 32'h03FC73C2;     //To give ADC clock at 16 MHz, MCOUNT = 1851, LCOUNT = 1347 for ADC
        data_memory[8]          = 32'h01E0F401;
        data_memory[9]          = 32'h00C00002;
        data_memory[10]         = 32'h08027FE4;     //Disable dividers for 16 MHz Clock, MCOUNT = 2046, LCOUNT = 2050 for ADC, ADC clock on Clock Out
        
        //Assigns default values to next-state variables
        state_next              <= idle;
        
        SDATA_reg_next          <= 1'bz;
        SCLK_en_next            <= 0;
        
        bit_next                <= 0;
        max_register_index_next <= 0;
        
        address_next            <= 4'h0;
        data_bits_next          <= 32'hBEA41503;
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin
        if (reset == 1)
        begin
            state                   <= idle;
                
            CSN_reg                 <= 1;
            SDATA_reg               <= 1'bz;
            SCLK_en                 <= 0;
                
            bit                     <= 0;
            max_register_index      <= 0;
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
            max_register_index      <= max_register_index_next;
        end
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Sequential Logic with Statemachine
    //--------------------------------------------------------------------------------------------------

    always @(negedge SPI_Tick) 
    begin
        state_next              <= state;
        
        CSN_reg_next            <= CSN_reg;
        SDATA_reg_next          <= SDATA_reg;
        SCLK_en_next            <= SCLK_en;
        
        bit_next                <= bit;
        max_register_index_next <= max_register_index;
        
        address_next            <= address_memory[max_register_index];
        data_bits_next          <= data_memory[max_register_index];
        
        case(state)
            idle: 
            begin
                CSN_reg_next                        <= 1;
                SCLK_en_next                        <= 1;
                SDATA_reg_next                      <= 1'bz;
                if (MAX_CONFIG_BEGIN == 1) 
                begin
                    state_next                      <= start;
                end
            end
            
            start: 
            begin
                CSN_reg_next                        <= 0;       //Drops CSN to initialise   
                SCLK_en_next                        <= 0;             
                if (bit < 8) 
                begin                                           //Frontloaded 0's for addresses
                    SDATA_reg_next                  <= 8'h00;
                    bit_next                        <= bit + 1;
                end 
                else if (bit < 12) 
                begin                                           //Addressing bits
                    SDATA_reg_next                  <= address[11-bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin                                           //Write process bit and change state
                    SDATA_reg_next                  <= 0;       //This line should last for 1 tick to indicate a write proccess
                    bit_next                        <= 0;
                    state_next                      <= data;
                end
            end
            
            data: 
            begin
                if (bit < 3) 
                begin                                           //0 state for TA bits
                    SDATA_reg_next                  <= 0;
                    bit_next                        <= bit + 1;
                end 
                else if (bit < 34) 
                begin                                           //Data bits
                    SDATA_reg_next                  <= data_bits[34-bit];
                    bit_next                        <= bit + 1;
                end 
                else 
                begin                                           //Holds previous data state before stop process
                    SDATA_reg_next                  <= data_bits[0];
                    bit_next                        <= 0;
                    state_next                      <= stop;
                end
            end
            
            stop: 
            begin                                               //Converts states back, resets variables and sets state back to idle
                CSN_reg_next                        <= 1;
                SCLK_en_next                        <= 1;
                SDATA_reg_next                      <= 1'bz;
                if (bit < 4) 
                begin
                    bit_next                        <= bit + 1;
                end 
                else 
                begin
                    bit_next                        <= 0;
                    if (max_register_index < 10) 
                    begin                                       //Limits the recursion of the statemachine to the number of registers in MAX2771
                            state_next              <= idle;
                            max_register_index_next <= max_register_index + 1;
                    end
                end
            end
        endcase
    end
    

    //--------------------------------------------------------------------------------------------------
    //  Assignment
    //--------------------------------------------------------------------------------------------------
    
    assign MAX_CSN      = CSN_reg;
    assign MAX_SCLK     = (!SCLK_en)? SPI_Tick:1'b0;
    assign MAX_SDATA    = SDATA_reg;
    
    
endmodule
