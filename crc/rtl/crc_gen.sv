// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/12/2023
// ------------------------------------------------------------------------------------------------
// Serial CRC generator
// ------------------------------------------------------------------------------------------------
// Read doc/crc.md to understand the algorithm to calculate the CRC.
// ------------------------------------------------------------------------------------------------

// This is a serial crc generator, the data bit will be shifted into the generator bit by bit.
// The original data will be shifted out first, and after the CRC calculation is done,
// the crc bits will be shifted out following the last bit of the data.

// This implementation assumes that shift start from MSB first.

module crc_gen #(
    parameter DW = 8,           // data width, data width
    parameter PW = 8,           // polynomial width
    parameter POLY = 8'h07,     // polynomial represented using normal form.
                                // default is CRC8-CCITT, 8'h01 => x^8 + x^2 + x + 1
    parameter [PW-1:0] INIT = 0 // initial value for the internal LFSR
) (
    input  logic            clk,
    input  logic            rst_b,

    input  logic [DW-1:0]   din,   // data for crc calculation
    input  logic            req,    // request to generate crc

    output logic            ready,  // generator is ready to take new data
    output logic            valid,  // crc generation is done.
    output logic [PW-1:0]   crc     // generated crc
);

    parameter CNT_WIDTH = $clog2(DW);

    logic                   take_req;   // take the new request
    logic                   calc_done;  // calculation done

    logic [PW-1:0]          lfsr_next;

    logic [DW-1:0]          data;
    logic [PW-1:0]          lfsr;
    logic [CNT_WIDTH:0]     counter;        // counter to count on the number of bits calculated


    /////////////////////////////////
    // flow control
    /////////////////////////////////

    assign take_req = req & ready;
    assign calc_done = counter == 0;
    assign valid = calc_done & ~ready;

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            ready <= 1'b1;
        end
        else begin
            if (take_req) begin
                ready <= 1'b0;
            end
            else if (calc_done) begin
                ready <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_b) begin
            counter <= 0;
            data <= 0;
        end
        else begin
            if (take_req) begin
                counter <= DW;
                data <= din;
            end
            // only do this when generator is running
            else if (!ready) begin
                counter <= counter - 1'b1;
                data <= data << 1;
            end
        end
    end

    /////////////////////////////////
    // LFSR to calculate crc
    /////////////////////////////////

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr <= INIT;
        end
        else if (take_req) begin
            lfsr <= INIT;
        end
        else if (!ready) begin
            lfsr <= lfsr_next;
        end
    end

    always @(*) begin
        // shift towards MSB
        lfsr_next[0] = lfsr[PW-1] ^ data[DW-1];
        for (int i = 1; i < PW; i = i + 1) begin
            if (POLY[i] == 1) begin
                lfsr_next[i] = lfsr[i-1] ^ lfsr_next[0];
            end
            else begin
                lfsr_next[i] = lfsr[i-1];
            end
        end
    end

    assign crc = lfsr;

endmodule
