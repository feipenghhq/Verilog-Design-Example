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

    logic [6:0]             dec_codeword;
    logic                   dec_extra_parity;

    logic [3:0]             dec_dout;
    logic                   dec_error_single_bit;
    logic                   dec_error_double_bit;
    logic [2:0]             syndrome;

    logic [3:0]             dec_dout_74;
    logic                   dec_error_single_bit_74;
    logic                   dec_error_double_bit_74;
    logic [2:0]             syndrome_74;

    ecc_hamming_encoder
    u_ecc_hamming_encoder (
        .din(din),
        .codeword(codeword),
        .extra_parity(extra_parity));

    ecc_hamming_74_encoder
    u_ecc_hamming_74_encoder (
        .din(din),
        .codeword(codeword_74),
        .extra_parity(extra_parity_74));

    ecc_hamming_decoder
    u_ecc_hamming_decoder (
        .codeword(dec_codeword),
        .extra_parity(dec_extra_parity),
        .dout(dec_dout),
        .error_single_bit(dec_error_single_bit),
        .error_double_bit(dec_error_double_bit),
        .syndrome(syndrome));

    ecc_hamming_74_decoder
    u_ecc_hamming_74_decoder (
        .codeword(dec_codeword),
        .extra_parity(dec_extra_parity),
        .dout(dec_dout_74),
        .error_single_bit(dec_error_single_bit_74),
        .error_double_bit(dec_error_double_bit_74),
        .syndrome(syndrome_74));

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(0, tb);
        end
    `endif

endmodule