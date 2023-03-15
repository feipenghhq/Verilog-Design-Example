// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/14/2023
// ------------------------------------------------------------------------------------------------
// Test bench for lfsr_galois
// ------------------------------------------------------------------------------------------------

module tb();

    localparam WIDTH=16;

    logic                clk;
    logic                rst_b;
    logic                load;
    logic                shift_en;
    logic [WIDTH-1:0]    lfsr_in;
    logic                din;
    logic [WIDTH-1:0]    lfsr_out_lsb;

    lfsr_galois #(.DIR("LSB"))
    u_lfsr_fibonacci(
        .lfsr_out(lfsr_out_lsb),
        .*
        );

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(0, tb);
        end
    `endif

endmodule