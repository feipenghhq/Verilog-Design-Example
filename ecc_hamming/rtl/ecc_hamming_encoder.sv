// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/09/2023
// ------------------------------------------------------------------------------------------------
// ECC using Hamming code
// ------------------------------------------------------------------------------------------------
// Note on the port width
// User can specify the actual data width they are using if it is smaller from a specific hamming code
// The output codeword is also shrinked based on the user specified data width.
// The encoder and decoder will automatically fill zeros to the unused bit for hamming code calculatios.
// This has certain benefits for not using the entire data width as the input:
//  1. It saves wires and storage elements (flip flop) from hardware
//  2. The unused bit may also be flipped hence create unnecessary errors.
// ------------------------------------------------------------------------------------------------

// See doc/hamming_code.md for more information about the hamming code.

module ecc_hamming_encoder #(
    // these are the configuration for the hamming code, default is (7, 4) hamming code
    parameter D = 4,        // number of data bits
    parameter DW = D,       // Acutal data bits used by the user
    parameter C = 7,        // number of codeword bits
    parameter SECDED = 1,   // 1 = use extra parity, 0 = no extra parity
    // These parameters are not supposed to be changed
    parameter P = C - D,    // number of parity bits
    parameter CW = DW + P   // acutal codeword size used by the user.

) (
    input  logic [D-1:0]    din,
    output logic [CW-1:0]   codeword,
    output logic            extra_parity
);

    // parity must at least be 2
    initial assert(P >= 2) else begin
        $error("ERROR: P must be greater than 2");
        $finish(1);
    end

    // user DW must be smaller then the maximum DW supported by this PW
    initial assert(DW <= D) else begin
        $error("ERROR: DW is too large. It must be smaller than the maximum data width supported by this hamming config");
        $finish(1);
    end

    logic [P-1:0]           parity_int;             // stores the parity bits
    logic [C-1:0]           codeword_int;           // stores the full codeword
    logic [C-1:0]           codeword_parity_cal;    // stores the input data into the actual bit location in the codeword
                                                    // used for parity calculation to avoid combination loop
    // For iverilog, this needs to be a traditional unpacked array
    logic [C/2:0]           parity_xor_bits[P-1:0]; // stores the bits that need to be xored for each parity


    // This is the alrogithm to calculate the hammding code
    // 1. Number the bits starting from 1: bit 1, 2, 3, 4, 5, 6, 7, etc
    // 2. All bit positions that are powers of two  are parity bits: 1, 2, 4, 8, etc. (1, 10, 100, 1000)
    // 3. All other bit positions are data bits
    // 4. Each data bit is included in a unique set of 2 or more parity bits, as determined by the binary form of its bit position
    //    1. Parity bit 1 covers all bit positions which have the least significant bit set: bit 1
    //    2. Parity bit 2 covers all bit positions which have the **second** least significant bit set
    //    3. Parity bit 4 covers all bit positions which have the **third** least significant bit set

    // For codeword_parity_cal, put data bits into it's corresponding locations, fill zeros if necessary
    int idx_i;
    always @(*) begin
        idx_i = 0;
        codeword_parity_cal = '0;
        for (int i = 1; i <= C; i++) begin
            if (!$onehot(i)) begin
                if (idx_i < DW) codeword_parity_cal[i-1] = din[idx_i];
                else            codeword_parity_cal[i-1] = 1'b0;
                idx_i = idx_i + 1;
            end
        end
    end

    // Store the bit into parity_xor_bits array for parity calculation
    int idx_j;
    always @* begin
        for (int i = 0; i < P; i = i + 1) begin
            parity_xor_bits[i] = '0;
        end
        //// scan through all the parity bits
        for (int i = 1; i <= P; i = i + 1) begin
            idx_j = 0;
            // scan through all the data bits
            for (int j = 1; j <= C; j = j + 1) begin
                if (j[i-1] == 1) begin
                    parity_xor_bits[i-1][idx_j] = codeword_parity_cal[j-1];
                    idx_j = idx_j + 1;
                end
            end
        end
    end

    // calculate the parity bit
    always @(*) begin
        parity_int = '0;
        for (int i = 0; i < P; i = i + 1) begin
            parity_int[i] = ^parity_xor_bits[i];
        end
    end

    // Put parity and data into it's corresponding locations, fill zeros if necessary
    int parity_idx, data_idx;

    always @(*) begin
        // reset the index bit
        parity_idx = 0;
        data_idx = 0;
        // set default value to zero.
        codeword_int = 0;

        // bit start at 1
        for (int i = 1; i <= C; i++) begin
            // This is a parity bit,
            if ($onehot(i)) begin
                codeword_int[i-1] = parity_int[parity_idx];
                parity_idx = parity_idx + 1;
            end
            // This is a data bit
            else begin
                if (data_idx < DW)  codeword_int[i-1] = din[data_idx];
                else                codeword_int[i-1] = 1'b0;
                data_idx = data_idx + 1;
            end
        end
    end

    assign codeword = codeword_int[CW-1:0];
    assign extra_parity = ^codeword;

endmodule