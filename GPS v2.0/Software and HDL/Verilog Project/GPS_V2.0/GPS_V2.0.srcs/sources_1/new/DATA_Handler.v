`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Skykraft
// Engineer:        Dino Colling
// 
// Create Date:     16.12.2025 15:27:56
// Design Name: 
// Module Name:     DATA_Handler
// Project Name:    Turtle GPS
// Target Devices: 
// Tool Versions: 
// Description:     1. When triggered it takes data 1 bit at a time from the ADC and stores it in a fifo
//                  2. Reads 460 bits from the FIFO at a time and compiles these into a 512 bit data packet with additional information
//                  3. Sends these bits to the LORA transmission module to downlink
//                  4. Repeats until FIFO is empty and transmission is complete
// 
// Dependencies:    None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DATA_Handler #(
        parameter   [7:0]       data_Transmission    = 8'h80, //Placeholder parameters to be overwritten
        parameter   [7:0]       period_Sample        = 0,
        parameter   [3:0]       data_Sample          = 0
    )
    (
        input wire              clk,
        input wire              SPI_Tick,
        input wire              ADC_CLK,
        input wire              tx_done,
        input wire  [1:0]       Data,
        input wire              SAMPLE_BEGIN,
        input wire              reset,
        input wire              tx_initialised,
        output wire [7:0]       packet_byte,
        output wire             tx_start,
        output wire             ADC_Tick
    );
    

    //--------------------------------------------------------------------------------------------------
    //  Parameters
    //--------------------------------------------------------------------------------------------------

    localparam fifo_data_count_max   = data_Transmission*1000;
    

    //--------------------------------------------------------------------------------------------------
    //  Registers for Data Packet
    //--------------------------------------------------------------------------------------------------

    reg [511:0] packet_reg                      = 0;

    reg [511:0] packet_reg_transfer             = 0;
    reg [7:0]   packet_reg_transfer_byte        = 0;
    reg [7:0]   packet_reg_transfer_byte_index  = 0;

    reg [10:0]  packet_data_index               = 0;
    reg [27:0]  USER_DEFINED_BITS               = 28'hfffffff;      //32 bits up to the user to define
    reg [11:0]  fifo_packet_index               = 12'h00;           //Index for transmission packets in a full fifo read
    reg [23:0]  satellite_id                    = 24'hf00b02;       //Satellite ID Code

    reg         changed                         = 1;
    reg         changed_d                       = 1;

    reg         tx_start_reg                    = 0;
    reg         TRANSMIT_BEGIN                  = 0;

    reg [30:0]  delay_reg                       = 0;
    reg [6:0]   counter                         = 0;

    reg [28:0] sample_counter                   = 0;
    reg [12:0] sample_loop                      = 1;
    

    //--------------------------------------------------------------------------------------------------
    //  Wires for FIFO
    //--------------------------------------------------------------------------------------------------

    wire full_flag;
    wire empty_flag;
    wire wr_en;
    wire rd_en;
    wire [1:0] dout;
    wire [1:0] din;
    wire sample_tick;
    
    
    //--------------------------------------------------------------------------------------------------
    //  Registers for FIFO
    //--------------------------------------------------------------------------------------------------

    reg wr_en_reg               = 0;
    reg rd_en_reg               = 0;
    reg [18:0] fifo_data_count  = 0;
    reg sample_tick_reg         = 0;
    

    //--------------------------------------------------------------------------------------------------
    //  ADC Clock Instantiation
    //--------------------------------------------------------------------------------------------------

    ADC_Clock ADC_CLOCK (
        .clk(clk),
        .ADC_CLK(ADC_CLK),
        .ADC_Tick(ADC_Tick)
    );
    

    //--------------------------------------------------------------------------------------------------
    //  Fifo instantiation
    //--------------------------------------------------------------------------------------------------

    fifo_gps_data FIFO (
        .wr_clk(sample_tick),
        .rd_clk(clk),
        .full(full_flag),
        .empty(empty_flag),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(Data),                                       //Links Data to FIFO data input
        .dout(dout)
    );


    //--------------------------------------------------------------------------------------------------
    //  Main Clock Sequential Logic and Reset
    //--------------------------------------------------------------------------------------------------

    always @(posedge clk) 
    begin
        if (reset == 1)
        begin
            TRANSMIT_BEGIN          <= 0;
            rd_en_reg               <= 0;
            wr_en_reg               <= 0;
            tx_start_reg            <= 0;

            changed                 <= 1;
            changed_d               <= 1;

            packet_reg              <= 0;
            packet_data_index       <= 0;
            fifo_packet_index       <= 0;
        end
        

        if ((SAMPLE_BEGIN == 1) && (fifo_data_count < fifo_data_count_max))     //Manages write to the FIFO and integrates the sample period and data length parameters
        begin
            if (data_Sample == 0)
            begin
                wr_en_reg           <= 1;
            end
            else
            begin
                if (fifo_data_count <= data_Sample*1000*sample_loop)
                begin
                    wr_en_reg       <= 1;
                end
                else if (sample_counter <= period_Sample*100_000)
                begin
                    sample_counter  <= sample_counter + 1;

                    wr_en_reg       <= 0;
                end
                else
                begin
                    sample_counter  <= 0;
                    sample_loop     <= sample_loop + 1;
                end
            end
        end
        else
        begin
            wr_en_reg               <= 0;
            
            if (fifo_data_count == fifo_data_count_max)
            begin
                TRANSMIT_BEGIN      <= 1;
            end
        end

        if ((tx_done == 0) && (changed == 0))                                   //Triggers on low of tx_done
        begin
            changed                 <= 1;
            tx_start_reg            <= 0;
        end 
        else if (tx_done == 1)
        begin
            changed                 <= 0;
        end

        if ((changed_d == 0) && (tx_done == 1))                                 //Triggers on high of tx_done
        begin
            changed_d               <= 1;

            delay_reg               <= 1;

            if (empty_flag == 0)                                                //Increments the packet index
            begin
                fifo_packet_index   <= fifo_packet_index + 1;
            end

            if (empty_flag == 1) 
            begin
                TRANSMIT_BEGIN      <= 0;
            end
        end
        else if (tx_done == 0)
        begin
            changed_d               <= 0;
        end

        if ((delay_reg != 0) && (delay_reg < 15_999_999))
        begin
            delay_reg <= delay_reg + 1;
        end
        else if (delay_reg == 15_999_999)
        begin
            delay_reg <= 0;
            if (empty_flag != 1) 
            begin
                packet_data_index   <= 0;
            end
        end

        if (TRANSMIT_BEGIN == 1)                                                //Builds data packet when triggered
        begin
            if (packet_data_index == 0)
            begin
                rd_en_reg           <= 1;
                packet_data_index   <= packet_data_index + 1;
            end 
            else if (packet_data_index < 449) 
            begin
                packet_reg          <= {packet_reg[509:0], dout};               //For LSB to MSB

                packet_data_index   <= packet_data_index + 2;

                if (packet_data_index == 447) begin
                    rd_en_reg       <= 0;
                end
            end
            else if (packet_data_index < 477) 
            begin
                packet_reg[475:448] <= USER_DEFINED_BITS;
                packet_data_index   <= 477;
            end 
            else if (packet_data_index < 489) 
            begin
                packet_reg[487:476] <= fifo_packet_index;
                packet_data_index   <= 489;
            end 
            else if (packet_data_index < 513)
            begin
                packet_reg[511:488] <= satellite_id;
                packet_data_index   <= 513;
                tx_start_reg        <= 1;
            end
        end
    end


    //--------------------------------------------------------------------------------------------------
    //  Additional Sequential Logic for indexing
    //--------------------------------------------------------------------------------------------------

    always @(posedge ADC_Tick)
    begin
        if ((fifo_data_count > 0) && (reset == 1)) begin
            fifo_data_count     <= 0;
        end

        if (counter == 15)
        begin
            if (wr_en_reg == 1)
            begin
                fifo_data_count     <= fifo_data_count + 1;
                sample_tick_reg     <= 1;
                counter             <= 0;
            end
        end
        else
        begin
            sample_tick_reg         <= 0;
            counter                 <= counter + 1;
        end
    end

    //--------------------------------------------------------------------------------------------------
    //  Additional Sequential Logic for packet transfer between modules
    //--------------------------------------------------------------------------------------------------

    localparam PACKET_BYTES = 64;

    always @(posedge SPI_Tick)
    begin
        if (tx_initialised == 0)
        begin
            if (packet_reg_transfer_byte_index < 1)
            begin
                packet_reg_transfer             <= packet_reg;

                packet_reg_transfer_byte_index  <= packet_reg_transfer_byte_index + 1;
            end
            else if (packet_reg_transfer_byte_index < PACKET_BYTES + 1)
            begin
                packet_reg_transfer_byte        <= packet_reg_transfer[7:0];
                packet_reg_transfer             <= {8'h00, packet_reg_transfer[511:8]};

                packet_reg_transfer_byte_index  <= packet_reg_transfer_byte_index + 1;
            end
        end
        else if (tx_initialised == 1)
        begin
            packet_reg_transfer_byte_index      <= 0;
        end
    end
    
    
    //--------------------------------------------------------------------------------------------------
    //  Assignments for FIFO and Transmission
    //--------------------------------------------------------------------------------------------------

    assign wr_en                = wr_en_reg;
    assign rd_en                = rd_en_reg;

    assign sample_tick          = sample_tick_reg;
    
    assign packet_byte          = packet_reg_transfer_byte;
    assign tx_start             = tx_start_reg;
    

endmodule
