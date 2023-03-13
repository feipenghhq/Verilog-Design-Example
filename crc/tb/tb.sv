// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/12/2023
// ------------------------------------------------------------------------------------------------
// Testbench for CRC
// ------------------------------------------------------------------------------------------------

module tb();

    logic            clk;
    logic            rst_b;

    /////////////////////////////////
    // Test for CRC8-CCITT
    /////////////////////////////////

    logic [7:0]     din_8;
    logic           req_8;
    logic           ready_8;
    logic           valid_8;
    logic [7:0]     crc_8;

    crc_gen #(
        .DW(8),
        .PW(8),
        .POLY(8'h9b),
        .INIT(8'hff)
    )
    u_crc8(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_8),
        .req(req_8),
        .ready(ready_8),
        .valid(valid_8),
        .crc(crc_8)
    );

    /////////////////////////////////
    // Test for CRC16
    /////////////////////////////////

    logic [15:0]     din_16;
    logic           req_16;
    logic           ready_16;
    logic           valid_16;
    logic [15:0]    crc_16;

    crc_gen #(
        .DW(16),
        .PW(16),
        .POLY(16'h1021),
        .INIT(16'hffff)
    )
    u_crc16(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_16),
        .req(req_16),
        .ready(ready_16),
        .valid(valid_16),
        .crc(crc_16)
    );

    //`ifdef COCOTB_SIM
    //    initial begin
    //        $dumpfile("dump.vcd");
    //        $dumpvars(0, tb);
    //    end
    //`endif

endmodule