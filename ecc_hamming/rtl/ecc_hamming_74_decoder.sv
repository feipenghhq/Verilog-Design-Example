// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/10/2023
// ------------------------------------------------------------------------------------------------
// ECC using (7, 4) Hamming code - decoder
// ------------------------------------------------------------------------------------------------


// See doc/hamming_code.md for more information about the hamming code.

module ecc_hamming_74_decoder (
    input  logic [6:0]    codeword,
    input  logic          extra_parity,
    output logic [3:0]    dout,
    output logic          error_single_bit,
    output logic          error_double_bit,
    output logic [2:0]    syndrome

);

    logic [3:0] data;
    logic [2:0] parity;
    logic       parity_error;
    logic       error;

    logic [6:0] correction_mask;
    logic [6:0] codeword_corrected;

    // extract parity from the codeword
    assign parity[0] = codeword[0];
    assign parity[1] = codeword[1];
    assign parity[2] = codeword[3];

    // extract the data from the codeword
    assign data[0] = codeword[2];
    assign data[1] = codeword[4];
    assign data[2] = codeword[5];
    assign data[3] = codeword[6];

    // calculate the syndrome
    // syndrome respresent the bit position that get flipped if it is not zero.
    // syndrome assumes that the codeword start from bit 1
    // so if syndrome = 1 then codeword[0] is flipped since our codeword start from bit 0
    assign syndrome[0] = parity[0] ^ data[0] ^ data[1] ^ data[3];
    assign syndrome[1] = parity[1] ^ data[0] ^ data[2] ^ data[3];
    assign syndrome[2] = parity[2] ^ data[1] ^ data[2] ^ data[3];

    // calculate the overall parity
    assign parity_error = (^codeword) ^ extra_parity;

    // check error
    assign error = |syndrome;                        // syndrom != 0 means there are errors
    assign error_single_bit = error & parity_error;  // if there are error and parity does not match, it's a single bit flip
    assign error_double_bit = error & ~parity_error; // if there are error and parity matches, it's a double bit flip

    // correct data if neccessary
    // need to right shift by 1 here because syndrome assumes that the codeword start from 1
    // but our codeword start from 0
    assign correction_mask = error_single_bit ? ((1 << syndrome) >> 1): '0;
    assign codeword_corrected = codeword ^ correction_mask;

    // send out data
    assign dout[0] = codeword_corrected[2];
    assign dout[1] = codeword_corrected[4];
    assign dout[2] = codeword_corrected[5];
    assign dout[3] = codeword_corrected[6];

endmodule