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

    ///////////////////////////////////////
    // Test for CRC8
    ///////////////////////////////////////

    localparam CRC8_POLY = 8'h9b;
    localparam CRC8_INIT = 8'hff;

    // 8 bit data input
    logic [7:0]     din_8;
    logic           req_8;
    logic           ready_8;
    logic           valid_8;
    logic [7:0]     crc_8;


    crc_gen_s #(
        .DW(8),
        .CW(8),
        .POLY(CRC8_POLY),
        .INIT(CRC8_INIT)
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

    logic [7:0]    din_8p;
    logic [7:0]    crc_8p;

    crc_gen_p #(
        .DW(8),
        .CW(8),
        .POLY(CRC8_POLY)
    )
    u_crc8p(
        .din(din_8p),
        .crc_in(CRC8_INIT),
        .crc_out(crc_8p)
    );


    // 16 bit data input

    logic [15:0]    din_8a;
    logic           req_8a;
    logic           ready_8a;
    logic           valid_8a;
    logic [7:0]     crc_8a;

    crc_gen_s #(
        .DW(16),
        .CW(8),
        .POLY(CRC8_POLY),
        .INIT(CRC8_INIT)
    )
    u_crc8a(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_8a),
        .req(req_8a),
        .ready(ready_8a),
        .valid(valid_8a),
        .crc(crc_8a)
    );

    logic [15:0]   din_8pa;
    logic [7:0]    crc_8pa;

    crc_gen_p #(
        .DW(16),
        .CW(8),
        .POLY(CRC8_POLY)
    )
    u_crc8pa(
        .din(din_8pa),
        .crc_in(CRC8_INIT),
        .crc_out(crc_8pa)
    );


    /////////////////////////////////
    // Test for CRC16
    /////////////////////////////////

    logic [15:0]    din_16;
    logic           req_16;
    logic           ready_16;
    logic           valid_16;
    logic [15:0]    crc_16;

    crc_gen_s #(
        .DW(16),
        .CW(16),
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

    ////////////////////////////////////////
    // Test for CRC16 with 8 bit data input
    ////////////////////////////////////////

    logic [7:0]     din_16a;
    logic           req_16a;
    logic           ready_16a;
    logic           valid_16a;
    logic [15:0]    crc_16a;

    crc_gen_s #(
        .DW(8),
        .CW(16),
        .POLY(16'h1021),
        .INIT(16'hffff)
    )
    u_crc16a(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_16a),
        .req(req_16a),
        .ready(ready_16a),
        .valid(valid_16a),
        .crc(crc_16a)
    );

    /////////////////////////////////
    // Test for CRC16 with 32 bit data
    /////////////////////////////////

    logic [31:0]    din_16b;
    logic           req_16b;
    logic           ready_16b;
    logic           valid_16b;
    logic [15:0]    crc_16b;

    crc_gen_s #(
        .DW(32),
        .CW(16),
        .POLY(16'h1021),
        .INIT(16'hffff)
    )
    u_crc16b(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_16b),
        .req(req_16b),
        .ready(ready_16b),
        .valid(valid_16b),
        .crc(crc_16b)
    );

    /////////////////////////////////
    // Test for CRC32
    /////////////////////////////////

    logic [31:0]    din_32;
    logic           req_32;
    logic           ready_32;
    logic           valid_32;
    logic [31:0]    crc_32;

    crc_gen_s #(
        .DW(32),
        .CW(32),
        .POLY(32'h04c11db7),
        .INIT(32'hffffffff)
    )
    u_crc32(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_32),
        .req(req_32),
        .ready(ready_32),
        .valid(valid_32),
        .crc(crc_32)
    );

    /////////////////////////////////
    // Test for CRC32 with 8 bit data
    /////////////////////////////////

    logic [7:0]     din_32a;
    logic           req_32a;
    logic           ready_32a;
    logic           valid_32a;
    logic [31:0]    crc_32a;

    crc_gen_s #(
        .DW(8),
        .CW(32),
        .POLY(32'h04c11db7),
        .INIT(32'hffffffff)
    )
    u_crc32a(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_32a),
        .req(req_32a),
        .ready(ready_32a),
        .valid(valid_32a),
        .crc(crc_32a)
    );

    /////////////////////////////////
    // Test for CRC32 with 16 bit data
    /////////////////////////////////

    logic [15:0]    din_32b;
    logic           req_32b;
    logic           ready_32b;
    logic           valid_32b;
    logic [31:0]    crc_32b;

    crc_gen_s #(
        .DW(16),
        .CW(32),
        .POLY(32'h04c11db7),
        .INIT(32'hffffffff)
    )
    u_crc32b(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_32b),
        .req(req_32b),
        .ready(ready_32b),
        .valid(valid_32b),
        .crc(crc_32b)
    );

    /////////////////////////////////
    // Test for CRC32 with 64 bit data
    /////////////////////////////////

    logic [63:0]    din_32c;
    logic           req_32c;
    logic           ready_32c;
    logic           valid_32c;
    logic [31:0]    crc_32c;

    crc_gen_s #(
        .DW(64),
        .CW(32),
        .POLY(32'h04c11db7),
        .INIT(32'hffffffff)
    )
    u_crc32c(
        .clk(clk),
        .rst_b(rst_b),
        .din(din_32c),
        .req(req_32c),
        .ready(ready_32c),
        .valid(valid_32c),
        .crc(crc_32c)
    );




endmodule