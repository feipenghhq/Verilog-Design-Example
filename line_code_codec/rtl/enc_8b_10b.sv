// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/22/2023
// ------------------------------------------------------------------------------------------------
// 8b/10b encoder
// ------------------------------------------------------------------------------------------------
// Reference:
// 1. Lattice 8b/10b Encoder/Decoder
// 2. https://github.com/freecores/1000base-x/blob/master/doc/01-581v1.pdf
// ------------------------------------------------------------------------------------------------

/*
--------------------------------------------------------
8b/10b Code Mapping:
--------------------------------------------------------

The 8b/10b encoder converts 8-bit code groups into 10-bit codes. The code groups include 256 data characters named
Dx.y and 12 control characters named Kx.y.

Code Group: Dx.y or Kx.y

       MSB                              LSB
      +---+---+---+     +---+---+---+---+---+
8b    | H | G | F |     | E | D | C | B | A |
      +---+---+---+     +---+---+---+---+---+
            y                     x

       MSB                                          LSB
      +---+---+---+---+---+---+         +---+---+---+---+
10b   | a | b | c | d | e | i |         | f | g | h | j |
      +---+---+---+---+---+---+         +---+---+---+---+

The coding scheme breaks the original 8-bit data into two blocks, 3 most significant bits (y) and 5 least significant bits
(x). From the most significant bit to the least significant bit, they are named as H, G, F and E, D, C, B, A. The 3-bit block is
encoded into 4 bits named j, h, g, f. The 5-bit block is encoded into 6 bits named i, e, d, c, b, a. As seen in Figure 3.1.,
the 4-bit and 6-bit blocks are then combined into a 10-bit encoded value.

--------------------------------------------------------
8b/10b Implementation:
--------------------------------------------------------

There are 2 implementation defined in the table

*/

module enc_8b_10b #(
    parameter IMPL = 0,          // implementation type: 0 - LUT based. 1 - Logic gate based.
    parameter OUT_FLOP = 1       // Add flop for output
) (
    input  logic        clk,
    input  logic        rst_b,

    input  logic [7:0]  datain_8b,  // 8-bit data input: HGFEDCBA
    input  logic        kin,        // character type control
    input  logic        rdispin,    // running disparity input. 0: RD = -1, 1: RD = +1
    output logic [9:0]  dataout_10b, // 10 bit data output: abcdeifghj
    output logic        rdispout,   // running disparity output
    output logic        k_err       // invalid control character requested
);

    // Look up table for code that has different encoding for different RD.
    // For each index, if the value is one then that code has different encoding.
    localparam X_RD_LUT = 32'b11101001100000011000000110010111;
    localparam Y_RD_LUT = 8'b10011001;

    generate
    if (IMPL == 0) begin: impl_lut

        logic [4:0] x;                      // x portion of the 8 bit input data
        logic [2:0] y;                      // y portion of the 8 bit input data

        logic [5:0] dx_enc_rd_minus;        // x portion of the encoded data for RD = -1
        logic [3:0] dy_enc_rd_minus;        // y portion of the encoded data for RD = -1
        logic [3:0] dy_enc_rd_minus_final;  // y portion of the encoded data for RD = -1
        logic       use_a7;                 // Use D.x.A7
        logic [5:0] dx_enc;                 // x portion of the encoded data
        logic [3:0] dy_enc;                 // y portion of the encoded data

        logic       x_select_positive_rd;
        logic       y_select_positive_rd;

        logic [2:0] num_ones_x;
        logic       rdisp_x_equal;

        logic       rdisp_after_x;          // running disparity after encoding x.
        logic       rdisp_after_y;          // running disparity after encoding both x and y.

        logic [5:0] kx_enc_rd_minus;        // x portion of the encoded control characters for RD = -1
        logic [3:0] ky_enc_rd_minus;        // y portion of the encoded control characters for RD = -1

        logic [5:0] kx_enc;     // x portion of the encoded control characters
        logic [3:0] ky_enc;     // y portion of the encoded control characters
        logic       kerr;

        logic [9:0] enc_10b;

        assign x = datain_8b[4:0];
        assign y = datain_8b[7:5];

        /////////////////////////////////
        // Data encoding for X portion
        /////////////////////////////////

        // This table here is for RD = −1
        // Notice that encoding for RD = +1 is the inversion of encoding for RD = -1
        // the final result are inverted if the actual RD is +1
        always @* begin
            case(x)
                5'd0 : dx_enc_rd_minus = 6'b100111;
                5'd1 : dx_enc_rd_minus = 6'b011101;
                5'd2 : dx_enc_rd_minus = 6'b101101;
                5'd3 : dx_enc_rd_minus = 6'b110001;
                5'd4 : dx_enc_rd_minus = 6'b110101;
                5'd5 : dx_enc_rd_minus = 6'b101001;
                5'd6 : dx_enc_rd_minus = 6'b011001;
                5'd7 : dx_enc_rd_minus = 6'b111000;
                5'd8 : dx_enc_rd_minus = 6'b111001;
                5'd9 : dx_enc_rd_minus = 6'b100101;
                5'd10: dx_enc_rd_minus = 6'b010101;
                5'd11: dx_enc_rd_minus = 6'b110100;
                5'd12: dx_enc_rd_minus = 6'b001101;
                5'd13: dx_enc_rd_minus = 6'b101100;
                5'd14: dx_enc_rd_minus = 6'b011100;
                5'd15: dx_enc_rd_minus = 6'b010111;
                5'd16: dx_enc_rd_minus = 6'b011011;
                5'd17: dx_enc_rd_minus = 6'b100011;
                5'd18: dx_enc_rd_minus = 6'b010011;
                5'd19: dx_enc_rd_minus = 6'b110010;
                5'd20: dx_enc_rd_minus = 6'b001011;
                5'd21: dx_enc_rd_minus = 6'b101010;
                5'd22: dx_enc_rd_minus = 6'b011010;
                5'd23: dx_enc_rd_minus = 6'b111010;
                5'd24: dx_enc_rd_minus = 6'b110011;
                5'd25: dx_enc_rd_minus = 6'b100110;
                5'd26: dx_enc_rd_minus = 6'b010110;
                5'd27: dx_enc_rd_minus = 6'b110110;
                5'd28: dx_enc_rd_minus = 6'b001110;
                5'd29: dx_enc_rd_minus = 6'b101110;
                5'd30: dx_enc_rd_minus = 6'b011110;
                5'd31: dx_enc_rd_minus = 6'b101011;
            endcase
        end

        assign x_select_positive_rd = X_RD_LUT[x] & rdispin;
        assign dx_enc = x_select_positive_rd ? ~dx_enc_rd_minus : dx_enc_rd_minus;

        // From the table we can find that if D.X code has only 1 encoding, then the running dispairty for X is netural.
        // If there are 2 encodings, then the running dispairty for X is either netural or positive.
        assign num_ones_x = dx_enc[0] + dx_enc[1] + dx_enc[2] + dx_enc[3] + dx_enc[4] + dx_enc[5];
        assign rdisp_x_equal = (num_ones_x == 3);
        assign rdisp_after_x = (X_RD_LUT[x] && !rdisp_x_equal) ? ~rdispin : rdispin;

        /////////////////////////////////
        // Data encoding for Y portion
        /////////////////////////////////

        // This table here is for RD = −1
        // Notice that encoding for RD = +1 is the inversion of encoding for RD = -1
        // the final result are inverted if the actual RD is +1
        always @* begin
            case(y)
                3'd0: dy_enc_rd_minus = 4'b0100;
                3'd1: dy_enc_rd_minus = 4'b1001;
                3'd2: dy_enc_rd_minus = 4'b0101;
                3'd3: dy_enc_rd_minus = 4'b1100;
                3'd4: dy_enc_rd_minus = 4'b1101;
                3'd5: dy_enc_rd_minus = 4'b1010;
                3'd6: dy_enc_rd_minus = 4'b0110;
                3'd7: dy_enc_rd_minus = 4'b1110;    // note: This is D.x.P7, special cases need for D.x.A7
            endcase
        end

        // use D.x.A7. D.x.A7 is used only
        // 1. when RD = −1: for x = 17, 18 and 20 and
        // 2. when RD = +1: for x = 11, 13 and 14.
        assign use_a7 = (y == 3'd7) & (
                            (~rdispin & ((x == 5'd17) | (x == 5'd18) | (x == 5'd20))) &
                            ( rdispin & ((x == 5'd11) | (x == 5'd13) | (x == 5'd14)))
                        );
        assign dy_enc_rd_minus_final = use_a7 ? 4'b0111 : dy_enc_rd_minus;


        // If the Y encoding has 2 values, then we need to chose the value based on the running disparity after
        // encoding x, so that the running disparity is within -1 and +1

        // Example 1: input RD = -1, input data is 3. We need to encode D.03.0
        // Encoding for D.03 is 110011 which doesn't change the running disparity as there are equals number of 0s and 1s.
        // Now for D.x.0 we need to select 1011 instead of 0100 because if we select 0100 then the new RD = +1.
        // But if we choose 0100 then the new RD = -3 which is wrong.

        // Example 2: input RD = -1, input data is 0. We need to encode D.00.0
        // Encoding for D.00 is 100111 which changes the RD from -1 to +1
        // Now for D.x.0 we need to select 0100 instead of 1011 to make new RD = -1
        // But if we select 1011 then the new RD will be +3

        // So the conclusion is that if after encoding X, RD is changed to -1, then we should select data with RD = +1
        // else if after encoding X, RD is changed to +1, then we should select data with RD = -1
        assign y_select_positive_rd = Y_RD_LUT[y] & ~rdisp_after_x;
        assign dy_enc = y_select_positive_rd ? ~dy_enc_rd_minus_final : dy_enc_rd_minus_final;

        assign rdisp_after_y = Y_RD_LUT[y] ? ~rdisp_after_x : rdisp_after_x;

        /////////////////////////////////
        // Control encoding
        /////////////////////////////////

        // The control symbols within 8b/10b are 10b symbols that are valid sequences of bits
        // (no more than six 1s or 0s) but do not have a corresponding 8b data byte.
        // The control symbols have the following patterns K.28.y or K.x.7

        assign kerr = kin & ((x != 5'd28) | (y != 3'd7));

        always @(*) begin
            case(x)
                5'd23: kx_enc_rd_minus = 6'b111010;
                5'd27: kx_enc_rd_minus = 6'b110110;
                5'd28: kx_enc_rd_minus = 6'b001111;
                5'd29: kx_enc_rd_minus = 6'b101110;
                5'd30: kx_enc_rd_minus = 6'b011110;
                default: kx_enc_rd_minus = {1'b0, x};
            endcase

            case(y)
                3'd0: ky_enc_rd_minus = 4'b0100;
                3'd1: ky_enc_rd_minus = 4'b1001;
                3'd2: ky_enc_rd_minus = 4'b0101;
                3'd3: ky_enc_rd_minus = 4'b0011;
                3'd4: ky_enc_rd_minus = 4'b0010;
                3'd5: ky_enc_rd_minus = 4'b1010;
                3'd6: ky_enc_rd_minus = 4'b0110;
                3'd7: ky_enc_rd_minus = 4'b1000;
            endcase
        end

        assign kx_enc = rdispin ? ~kx_enc_rd_minus : kx_enc_rd_minus;
        assign ky_enc = rdispin ? ~ky_enc_rd_minus : ky_enc_rd_minus;

        /////////////////////////////////
        // calculate running disparity
        /////////////////////////////////

        assign enc_10b = kin ? {kx_enc, ky_enc} : {dx_enc, dy_enc};
        assign rdisp = rdisp_after_y;

        /////////////////////////////////
        // Final output
        /////////////////////////////////
        if (OUT_FLOP) begin: out_flop

            always @(posedge clk or negedge rst_b) begin
                if (!rst_b) begin
                    dataout_10b <= 10'd0;
                    rdispout <= 1'b0;       // default RD = -1
                    k_err <= 1'b0;
                end
                else begin
                    dataout_10b <= enc_10b;
                    rdispout <= rdisp;
                    k_err <= kerr;
                end
            end

        end: out_flop
        else begin: no_out_flop

            assign dataout_10b = enc_10b;
            assign rdispout = rdisp;
            assign k_err = kerr;

        end: no_out_flop

    end: impl_lut

    endgenerate

endmodule