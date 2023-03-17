// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/16/2023
// ------------------------------------------------------------------------------------------------
// Testbench for Parallel Galois LFSR
// ------------------------------------------------------------------------------------------------

module tb();

    localparam WIDTH = 16;
    localparam N = 16;

    logic [WIDTH-1:0]    lfsr_in;
    logic [N-1:0]        data;
    logic [WIDTH-1:0]    lfsr_outa;
    logic [WIDTH-1:0]    lfsr_outb;

    lfsr_galois_p
    u_lfsr_galois_p (
        .lfsr_in(lfsr_in),
        .data(data),
        .lfsr_out(lfsr_outa));

    lfsr_0x6801_W16_D0
    u_lfsr_0x6801_W16_D0 (
        .lfsr_in(lfsr_in),
        .lfsr_out(lfsr_outb));

endmodule