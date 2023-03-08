// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/03/2023
// ------------------------------------------------------------------------------------------------
// An example 8 bit scrambler
// ------------------------------------------------------------------------------------------------
// Example taken from the book <Advanced Chip Design Practical Examples in Verilog>
// Chapter 6.2.7 PCIe Scrambler
//
// Features:
//      - 8 bit scrambler, the data input and output are 8 bit wide
//      - The LFSR polynomial is X^16 + X^5 + X^4 + X^3 + 1
//      - The LFSR is initialized to 16'hFFFF
//      - COM character that initialize LFSR is 8'hBC
//      - The SKIP character is 8'h1C
// Notes:
//      - Control work will not be scrambled
//      - SKIP command will pasue the scrambler, LFSR will not be advanced
//      - dis_scramble will disable scrambling the data but the LFSR is still advanced
// ------------------------------------------------------------------------------------------------

module scrambler_8bit #(
    parameter SEED = 16'hFFFF,
    parameter COM = 8'hBC,
    parameter SKIP = 8'h1C
)(
    input logic             clk,
    input logic             rst_b,

    input logic [7:0]       din,
    input logic             k_in,               // 1 = control word, 0 = data word
    input logic             dis_scrambler_in,   // if set to one, do not scramble a data but still advance the LFSR flops.

    output logic            k_out,
    output logic            dis_scrambler_out,
    output logic  [7:0]     dout
);

    logic [15:0]    lfsr_next;
    logic [15:0]    lfsr_current;
    logic [7:0]     data_scrambled;
    logic           is_skip;
    logic           is_sync;

    assign is_skip = k_in & (din == SKIP);   // don't advance the LFSR
    assign is_sync = k_in & (din == COM);    // reset the lfsr to the initial value

    assign data_scrambled = din ^ lfsr_current[7:0];

    // Update the output data
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            k_out <= '0;
            dis_scrambler_out <= '0;
            dout <= '0;
        end
        else begin
            k_out <= k_in;
            dis_scrambler_out <= dis_scrambler_in;
            if (k_in || dis_scrambler_in)
                dout <= din;
            else
                dout <= data_scrambled;
        end
    end

    // Update LFSR
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr_current <= SEED;
        end
        else begin
            if (is_sync)
                lfsr_current <= SEED;
            else if (!is_skip)
                lfsr_current <= lfsr_next;
        end
    end

    // Parallel LFSR Calculate
    always @(*) begin
        lfsr_next[0] = lfsr_current[8];
        lfsr_next[1] = lfsr_current[9];
        lfsr_next[2] = lfsr_current[10];
        lfsr_next[3] = lfsr_current[8] ^ lfsr_current[11];
        lfsr_next[4] = lfsr_current[8] ^ lfsr_current[9] ^ lfsr_current[12];
        lfsr_next[5] = lfsr_current[8] ^ lfsr_current[9] ^ lfsr_current[10] ^ lfsr_current[13];
        lfsr_next[6] = lfsr_current[9] ^ lfsr_current[10] ^ lfsr_current[11] ^ lfsr_current[14];
        lfsr_next[7] = lfsr_current[10] ^ lfsr_current[11] ^ lfsr_current[12] ^ lfsr_current[15];
        lfsr_next[8] = lfsr_current[0] ^ lfsr_current[11] ^ lfsr_current[12] ^ lfsr_current[13];
        lfsr_next[9] = lfsr_current[1] ^ lfsr_current[12] ^ lfsr_current[13] ^ lfsr_current[14];
        lfsr_next[10] = lfsr_current[2] ^ lfsr_current[13] ^ lfsr_current[14] ^ lfsr_current[15];
        lfsr_next[11] = lfsr_current[3] ^ lfsr_current[14] ^ lfsr_current[15];
        lfsr_next[12] = lfsr_current[4] ^ lfsr_current[15];
        lfsr_next[13] = lfsr_current[5];
        lfsr_next[14] = lfsr_current[6];
        lfsr_next[15] = lfsr_current[7];
    end

endmodule