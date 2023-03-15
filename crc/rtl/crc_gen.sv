// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/12/2023
// ------------------------------------------------------------------------------------------------
// Serial CRC generator
// Read doc/crc.md to understand the algorithm to calculate the CRC.
// ------------------------------------------------------------------------------------------------

/*

The CRC generation used Galois LFSR.
Here is an example using the following CRC polynomial
CRC-8: x^8 + x^2 + x + 1
Poly: 0x07
Galois LFSR used to calculate the CRC:

                            shift direction
                            <--------------

      +---+---+---+---+---+---+      +---+      +---+             +------+
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<----(+)<----| data |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |      +------+
        |                         |          |             |
        |                         |          |             |
        +-------------------------+----------+------------->

*/

module crc_gen #(
    parameter DW = 8,           // data width, data width
    parameter PW = 8,           // polynomial width
    parameter POLY = 8'h07,     // polynomial represented using normal form.
                                // default is CRC8-CCITT, 8'h01 => x^8 + x^2 + x + 1
    parameter [PW-1:0] INIT = 0 // initial value for the internal LFSR
) (
    input  logic            clk,
    input  logic            rst_b,

    input  logic [DW-1:0]   din,    // data for crc calculation
    input  logic            req,    // request to generate crc

    output logic            ready,  // generator is ready to take new data
    output logic            valid,  // crc generation is done.
    output logic [PW-1:0]   crc     // generated crc
);

    localparam CNT_WIDTH = $clog2(DW);
    localparam REM_WIDTH = (DW > PW) ? (DW - PW) : 1;   // remaining data width

    logic                   take_req;   // take the new request
    logic                   calc_done;  // calculation done
    logic                   lfsr_en;
    logic [PW-1:0]          lfsr_in;
    logic [REM_WIDTH-1:0]   data_remaining;

    logic [CNT_WIDTH:0]     counter;    // counter to count on the number of bits calculated

    /////////////////////////////////
    // flow control
    /////////////////////////////////

    assign take_req = req & ready;
    assign calc_done = counter == 0;
    assign valid = calc_done & ~ready;
    assign lfsr_en = take_req | ~calc_done;

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
        end
        else begin
            if (take_req) begin
                counter <= DW;
            end
            // only do this when generator is running
            else if (!ready) begin
                counter <= counter - 1'b1;
            end
        end
    end

    /////////////////////////////////
    // LFSR to calculate crc
    /////////////////////////////////

    // take care of the input data

    generate
        if (DW > PW) begin

            assign lfsr_in = din[DW-1:DW-PW] ^ INIT;

            always @(posedge clk or rst_b) begin
                if (!rst_b) begin
                    data_remaining <= 0;
                end
                else begin
                    if (take_req) begin
                        data_remaining <=  din[DW-PW-1:0];
                    end
                    else if (!ready) begin
                        data_remaining <= data_remaining << 1;
                    end
                end
            end

        end
        else if (DW == PW) begin
            assign lfsr_in = din ^ INIT;
            assign data_remaining = 1'b0;
        end
        else if (DW < PW) begin
            assign lfsr_in = {din, {(PW-DW){1'b0}}} ^ INIT;
            assign data_remaining = 1'b0;
        end
    endgenerate

    // instantiate the LFSR module
    lfsr_galois #(
        .DIR("MSB"),
        .WIDTH(PW),
        .POLY(POLY),
        .INIT(INIT)
    )
    u_lfsr_galois (
        .clk(clk),
        .rst_b(rst_b),
        .load(take_req),
        .shift_en(lfsr_en),
        .lfsr_in(lfsr_in),
        .din(data_remaining[REM_WIDTH-1]),
        .lfsr_out(crc)
    );

endmodule
