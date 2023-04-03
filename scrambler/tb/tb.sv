// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/07/2023
// ------------------------------------------------------------------------------------------------
// Test bench for Scrambler
// ------------------------------------------------------------------------------------------------

module tb();

    logic           clk;
    logic           rst_b;

    logic [7:0]     din;
    logic           k_in;
    logic           dis_scrambler;

    logic           scm_k_out;
    logic           scm_dis_scrambler_out;
    logic [7:0]     scm_dout;

    logic [7:0]     descm_dout;

    scrambler_pcie u_scrambler(
        .clk(clk),
        .rst_b(rst_b),
        .din(din),
        .k_in(k_in),
        .dis_scrambler_in(dis_scrambler),
        .k_out(scm_k_out),
        .dis_scrambler_out(scm_dis_scrambler_out),
        .dout(scm_dout));

    scrambler_pcie u_descrambler(
        .clk(clk),
        .rst_b(rst_b),
        .din(scm_dout),
        .k_in(scm_k_out),
        .dis_scrambler_in(scm_dis_scrambler_out),
        .k_out(),
        .dis_scrambler_out(),
        .dout(descm_dout));

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile("test.vcd");
            $dumpvars(0, tb);
        end
    `endif

endmodule