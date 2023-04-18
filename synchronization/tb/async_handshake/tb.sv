// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/17/2023
// ------------------------------------------------------------------------------------------------
// Testbench for handshake synchronization
// ------------------------------------------------------------------------------------------------

`timescale 1ns/10ps

module tb();

    logic clk_50;
    logic rst_b_50;
    logic clk_100;
    logic rst_b_100;
    logic [7:0] tx_data_1;
    logic tx_valid_1;
    logic tx_ready_1;
    logic [7:0] rx_data_1;
    logic rx_valid_1;
    logic [7:0] tx_data_2;
    logic tx_valid_2;
    logic tx_ready_2;
    logic [7:0] rx_data_2;
    logic rx_valid_2;

    // clock and resets
    initial begin
        clk_50 = 0;
        forever begin
            clk_50 = #20 ~clk_50;
        end
    end

    initial begin
        rst_b_50 = 0;
        @(posedge clk_50);
        @(negedge clk_50);
        rst_b_50 = 1;
    end

    initial begin
        clk_100 = 0;
        forever begin
            clk_100 = #10 ~clk_100;
        end
    end

    initial begin
        rst_b_100 = 0;
        @(posedge clk_100);
        @(negedge clk_100);
        rst_b_100 = 1;
    end

    initial begin
        tx_data_1 = 0;
        tx_valid_1 = 0;
        wait (rst_b_50 & rst_b_100);
        @(posedge clk_100);
        @(negedge clk_100);
        tx_valid_1 = 1;
        tx_data_1 = 8'h55;
        @(negedge clk_100);
        tx_valid_1 = 0;
        tx_data_1 = 0;
        #400;
        $finish();
    end

    initial begin
        tx_data_2 = 0;
        tx_valid_2 = 0;
        wait (rst_b_50 & rst_b_100);
        @(posedge clk_50);
        @(negedge clk_50);
        tx_valid_2 = 1;
        tx_data_2 = 8'h55;
        @(negedge clk_50);
        tx_valid_2 = 0;
        tx_data_2 = 0;
        #400;
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    async_handshake
    u_async_handshake_fast2slow(
        .tx_clk(clk_100),
        .tx_rst_b(rst_b_100),
        .tx_data(tx_data_1),
        .tx_valid(tx_valid_1),
        .tx_ready(tx_ready_1),
        .rx_clk(clk_50),
        .rx_rst_b(rst_b_50),
        .rx_data(rx_data_1),
        .rx_valid(rx_valid_1)
    );

    async_handshake
    u_async_handshake_slow2fast(
        .tx_clk(clk_50),
        .tx_rst_b(rst_b_50),
        .tx_data(tx_data_2),
        .tx_valid(tx_valid_2),
        .tx_ready(tx_ready_2),
        .rx_clk(clk_100),
        .rx_rst_b(rst_b_100),
        .rx_data(rx_data_2),
        .rx_valid(rx_valid_2)
    );

endmodule