// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/16/2023
// ------------------------------------------------------------------------------------------------
// Parallel CRC generator
// This module use the parallel LFSR module to calculate CRC in one cycle
// ------------------------------------------------------------------------------------------------

/*
------------------------------------------------------------------------------------------------
Example Galois LFSR used to calculate the CRC:
------------------------------------------------------------------------------------------------
CRC-8: x^8 + x^2 + x + 1
Poly: 0x07
                            shift direction
                            <--------------

      +---+---+---+---+---+---+      +---+      +---+             +------+
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<----(+)<----| data |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |      +------+
        |                         |          |             |
        |                         |          |             |
        +-------------------------+----------+------------->

------------------------------------------------------------------------------------------------
Cascading CRC calculation:
------------------------------------------------------------------------------------------------

We can cascade the calculation of CRC if the number of bits to be calculated is greater then the number of polynomial
bits to get better timing, (but we need more cycle to do so.)

For example, if we want to calcualte 128 bit data using 32 bit CRC, we can use a crc_gen module with 128 as DW (data width)
and 32 as CW (polynomial width). However, this might create timing issue since the number of bits that are getting XOR-ed
will be large.

Instead, we can use a crc_gen module with 32 bit data and 32 bit polynomial, and calculate 32 bits of data at each cycle.
But we need 4 cycles to calculate the CRC of the entire number. This is a design trade off between timing, and latency.

To do the above calculation, we divide the 128 bit data into 4 32 bit data, denoted as D0, D1, D2, D3, starting from MSB.
In the first cycle, din = D0, crc_in = initial value of the polynomial, and we get a crc output as crc_out_1.
In the second cycle, din = D1, crc_in = crc_out_1, and we get a crc output as crc_out_2.
In the third cycle, din = D2, crc_in = crc_out_2, and we get a crc output as crc_out_3.
In the fourth cycle, din = D3, crc_in = crc_out_3, and we get a crc output as the final crc value.
*/

module crc_gen_p #(
    parameter DW = 8,           // data width
    parameter CW = 8,           // crc width
    parameter POLY = 8'h07      // polynomial represented using normal form.
                                // default is CRC8-CCITT, 8'h01 => x^8 + x^2 + x + 1
) (
    input  logic [DW-1:0]   din,    // data for crc calculation
    input  logic [CW-1:0]   crc_in, // initial polynomial value or prevoious CRC value
    output logic [CW-1:0]   crc_out // generated crc
);

    logic [CW-1:0] lfsr_init;
    logic [DW-1:0] data_remaining;

    // Based on our Galois LFSR structure, the LFSR initial value should be din[upper CW width] ^ crc_in
    // which is the same as serial CRC calculation in crc_gen.sv
    generate
        if (DW == CW) begin
            assign lfsr_init = din ^ crc_in;
            assign data_remaining = 0;
        end
        // fill zero to extend data width
        else if (DW < CW) begin
            assign lfsr_init = {din, {(CW-DW){1'b0}}} ^ crc_in;
            assign data_remaining = 0;
        end
        else if (DW > CW) begin
            assign lfsr_init = din[DW-1:DW-CW] ^ crc_in;
            assign data_remaining = {din[DW-CW-1:0], {(DW-CW){1'b0}}};
        end
    endgenerate

    // Use a parallel Galois LFSR
    lfsr_galois_p #(
        .D_WIDTH(DW),
        .WIDTH(CW),
        .DIR("MSB"),
        .POLY(POLY)
    )
    u_lfsr_galois_p(
        .lfsr_in(lfsr_init),
        .data(data_remaining),
        .lfsr_out(crc_out)
    );

endmodule