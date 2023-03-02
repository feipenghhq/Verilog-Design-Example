// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/01/2023
// ------------------------------------------------------------------------------------------------
// Fibonacci LFSR
// ------------------------------------------------------------------------------------------------
// Fibonacci LFSR: Output of multiple flops are used in XOR to drive the input of the first flop
// https://en.wikipedia.org/wiki/File:LFSR-F16.svg
// ------------------------------------------------------------------------------------------------

module lfsr_fibonacci #(
    parameter WIDTH = 16,       // Width of the LFSR
    parameter TAPS = 16'hB400,  // each bit in the tap represents whether the term in the
                                // feedback polynomial is set or not. It starts from term x^1
                                // 16'hb400 => x^16 + x^14 + x^13 + x^11 + 1
    parameter SEED = 16'hACE1   // Initial seed for the LFSR.
) (
    input  logic                clk,
    input  logic                rst_b,
    output logic [WIDTH-1:0]    lfsr_out
);

    logic [WIDTH-1:0]           lfsr_reg;
    logic                       tap_bit;

    // tap bit is the xor result of the flop bits where the corresponing TAPS bit is set to 1
    // For exampe, if TAPS = 16'hB400 = 16'b1011_0100_0000_0000,
    // bit 15, bit 13, bit 12, bit 10 are set, so
    // tap_bit = lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10]
    always_comb begin
        tap_bit = 1'b0; // initialized to zero at the beginning.
        for (int i = 0; i < WIDTH; i++) begin: tap_bit_xor
            // If the tap bit is set in this position, then
            // we need to xor this bit from the lfsr register
            if (TAPS[i]) begin
                tap_bit = tap_bit ^ lfsr_reg[i];
            end
        end
    end


    always_ff @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr_reg <= SEED;
        end
        else begin
            // Doing a right shift here
            lfsr_reg <= {tap_bit, lfsr_reg[WIDTH-1:1]};
        end
    end

    assign lfsr_out = lfsr_reg;

endmodule
