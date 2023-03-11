// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/10/2023
// ------------------------------------------------------------------------------------------------
// ECC using (7, 4) Hamming code
// ------------------------------------------------------------------------------------------------


// See doc/hamming_code.md for more information about the hamming code.

module ecc_hamming_74_encoder (
    input  logic [3:0]      din,
    output logic [6:0]      codeword,
    output logic            extra_parity
);

    assign codeword[0] = din[0] ^ din[1] ^ din[3];  // parity
    assign codeword[1] = din[0] ^ din[2] ^ din[3];  // parity
    assign codeword[2] = din[0];
    assign codeword[3] = din[1] ^ din[2] ^ din[3];  // parity
    assign codeword[4] = din[1];
    assign codeword[5] = din[2];
    assign codeword[6] = din[3];

    assign extra_parity = ^codeword;

endmodule