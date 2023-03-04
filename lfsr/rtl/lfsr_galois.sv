// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/03/2023
// ------------------------------------------------------------------------------------------------
// Galois LFSR
// ------------------------------------------------------------------------------------------------
// Galois LFSR: Output of one flop is used in XOR to drive the input of the multiple flop
// https://en.wikipedia.org/wiki/Linear-feedback_shift_register#/media/File:LFSR-G16.svg
// ------------------------------------------------------------------------------------------------

module lfsr_galois #(
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
    logic [WIDTH-1:0]           lfsr_right_shifted;
    logic                       tap_bit;

    assign lfsr_right_shifted = {lfsr_reg[0], lfsr_reg[WIDTH-1:1]};

    always_ff @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr_reg <= SEED;
        end
        else begin
            for (int i = 0; i < WIDTH - 1; i = i + 1) begin
                // if the corresponding tap bit is set to 1, then
                // we need to take the xor result of the previous flop and
                // the first bit
                if (TAPS[i]) lfsr_reg[i] <= lfsr_right_shifted[i] ^ lfsr_reg[0];
                else lfsr_reg[i] <= lfsr_right_shifted[i];
            end
            // the last bit is just takes the frist bit
            lfsr_reg[WIDTH-1] <= lfsr_right_shifted[WIDTH-1];
        end
    end

    assign lfsr_out = lfsr_reg;

endmodule
