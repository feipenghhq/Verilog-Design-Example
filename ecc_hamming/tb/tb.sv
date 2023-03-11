// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/09/2023
// ------------------------------------------------------------------------------------------------
// Test bench for hamming code
// ------------------------------------------------------------------------------------------------

module tb();

    reg [3:0]               din;        // 4 bit of data
    wire [6:0]              codeword;   // 7 bit of codeword
    wire                    extra_parity;

    wire [6:0]              codeword_74;
    wire                    extra_parity_74;

    // test for a (7, 4) hamming code
    ecc_hamming_encoder #(
        .D(4),
        .C(7),
        .SECDED(1))
    u_ecc_hamming_encoder (
        .din(din),
        .codeword(codeword),
        .extra_parity(extra_parity));

    ecc_hamming_74_encoder
    u_ecc_hamming_74_encoder (
        .din(din),
        .codeword(codeword_74),
        .extra_parity(extra_parity_74));

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile("test.vcd");
            $dumpvars(0, tb);
        end
    `endif

endmodule