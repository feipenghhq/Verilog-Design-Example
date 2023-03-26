// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/24/2023
// ------------------------------------------------------------------------------------------------
// testbench for 8b/10b encoder
// ------------------------------------------------------------------------------------------------

module tb();

    logic        clk;
    logic        rst_b;

    logic [7:0]  datain_8b;
    logic        kin;
    logic        rdispin;
    logic [9:0]  dataout_10b;
    logic        rdispout;
    logic        k_err;

    enc_8b_10b u_enc_8b_10b(.*);

    //`ifdef COCOTB_SIM
    //    initial begin
    //        $dumpfile("dump.vcd");
    //        $dumpvars(0, tb);
    //    end
    //`endif

endmodule