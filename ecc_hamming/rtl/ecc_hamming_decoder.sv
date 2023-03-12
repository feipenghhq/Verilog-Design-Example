// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/10/2023
// ------------------------------------------------------------------------------------------------
// ECC using Hamming code - decoder
// ------------------------------------------------------------------------------------------------


// See doc/hamming_code.md for more information about the hamming code.

module ecc_hamming_decoder #(
    // these are the configuration for the hamming code, default is (7, 4) hamming code
    parameter D = 4,        // number of data bits
    parameter DW = D,       // Acutal data bits used by the user
    parameter C = 7,        // number of codeword bits
    parameter SECDED = 1,   // 1 = use extra parity, 0 = no extra parity
    // These parameters are not supposed to be changed
    parameter P = C - D,    // number of parity bits
    parameter CW = DW + P   // acutal codeword size used by the user.

) (
    input  logic [CW-1:0]   codeword,
    input  logic            extra_parity,
    output logic [DW-1:0]   dout,
    output logic            error_single_bit,
    output logic            error_double_bit,
    output logic [P-1:0]    syndrome
);


    logic [D-1:0]   data;
    logic [P-1:0]   parity;
    logic           parity_error;
    logic           error;

    logic [C-1:0]   correction_mask;
    logic [C-1:0]   codeword_corrected;

    logic [C/2:0]   syndrome_xor_bits[P-1:0];   // array to store the bit to be xored to calculate the syndrome

    // extract parity from the codeword
    always @(*) begin
        for (int i = 0; i < P; i = i + 1) begin
            parity[i] = codeword[(1 << i)-1];
        end
    end

    // extract the data from the codeword
    int idx_d;
    always @(*) begin
        idx_d = 0;
        // the hamming code algorithm starts with bit 1
        for (int i = 1; i <= C; i = i + 1) begin
            // not parity field -> data field
            if (!$onehot(i)) begin
                data[idx_d] = codeword[i-1];
                idx_d = idx_d + 1;
            end
        end
    end

    // calculate the syndrome
    // syndrome respresent the bit position that get flipped if it is not zero.
    // syndrome assumes that the codeword start from bit 1
    // so if syndrome = 1 then codeword[0] is flipped since our codeword start from bit 0
    int idx_s;
    always @(*) begin
        for (int i = 1; i <= P; i = i + 1) begin
            idx_s = 0;
            for (int j = 1; j <= C; j = j + 1) begin
                if (j[i-1] == 1) begin
                    syndrome_xor_bits[i-1][idx_s] = codeword[j-1];
                    idx_s = idx_s + 1;
                end
            end
        end
    end

    // XOR all the bits together to get the syndrome
    always @(*) begin
        for (int i = 0; i < P; i = i + 1) begin
            syndrome[i] = ^ syndrome_xor_bits[i];
        end
    end

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
    int idx_i;
    always @(*) begin
        idx_i = 0;
        for (int i = 1; i <= C; i = i + 1) begin
            // not parity field -> data field
            if (!$onehot(i)) begin
                dout[idx_i] = codeword_corrected[i-1];
                idx_i = idx_i + 1;
            end
        end
    end

endmodule