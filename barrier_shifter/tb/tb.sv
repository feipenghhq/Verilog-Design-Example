// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/12/2023
// ------------------------------------------------------------------------------------------------
// Testbench for Barrier Shifter
// ------------------------------------------------------------------------------------------------

module tb();

    logic [7:0] din8, dout8l, dout8r;
    logic [2:0] shift8;

    barrier_shifter #(.WIDTH(8), .DIRECTION("L"))
    u_barrier_shifter_8l (.din(din8), .shift(shift8), .dout(dout8l));

    barrier_shifter #(.WIDTH(8), .DIRECTION("R"))
    u_barrier_shifter_8r (.din(din8), .shift(shift8), .dout(dout8r));

    logic [11:0] din12, dout12l, dout12r;
    logic [3:0] shift12;

    barrier_shifter #(.WIDTH(12), .DIRECTION("L"))
    u_barrier_shifter_12l (.din(din12), .shift(shift12), .dout(dout12l));

    barrier_shifter #(.WIDTH(12), .DIRECTION("R"))
    u_barrier_shifter_12r (.din(din12), .shift(shift12), .dout(dout12r));

    //`ifdef COCOTB_SIM
    //    initial begin
    //        $dumpfile("dump.vcd");
    //        $dumpvars(0, tb);
    //    end
    //`endif

endmodule
