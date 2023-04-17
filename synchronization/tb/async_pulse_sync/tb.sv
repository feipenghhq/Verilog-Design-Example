// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/16/2023
// ------------------------------------------------------------------------------------------------
// Testbench for Pluse synchronization
// ------------------------------------------------------------------------------------------------

`timescale 1ns/10ps

module tb();

    logic clk_50;
    logic rst_b_50;
    logic clk_100;
    logic rst_b_100;
    logic pulse_in_1;
    logic pulse_out_1;
    logic pulse_in_2;
    logic pulse_out_2;

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

    // test slow clock to fast clock
    initial begin
        pulse_in_1 = 0;
        wait (rst_b_50 & rst_b_100);
        @(posedge clk_50);
        pulse_in_1 = 1;
        @(posedge clk_50);
        pulse_in_1 = 0;
        @(posedge clk_50);
        pulse_in_1 = 1;
        @(posedge clk_50);
        pulse_in_1 = 0;
        @(posedge clk_50);
        pulse_in_1 = 1;
        @(posedge clk_50);
        pulse_in_1 = 0;
        #200;
        $finish();
    end

    // test fast clock to slow clock
    // Need to have at least 3 clock gaps for each pulse to
    // make it working properly
    initial begin
        pulse_in_2 = 0;
        wait (rst_b_50 & rst_b_100);
        @(posedge clk_100);
        pulse_in_2 = 1;
        @(posedge clk_100);
        pulse_in_2 = 0;
        @(posedge clk_100);
        @(posedge clk_100);
        @(posedge clk_100);
        pulse_in_2 = 1;
        @(posedge clk_100);
        pulse_in_2 = 0;
        @(posedge clk_100);
        @(posedge clk_100);
        @(posedge clk_100);
        pulse_in_2 = 1;
        @(posedge clk_100);
        pulse_in_2 = 0;
        #200;
        $finish();
    end

    async_pulse_sync
    u_async_pulse_sync_slow2fast(
        .tx_clk(clk_50),
        .tx_rst_b(rst_b_50),
        .tx_pulse(pulse_in_1),
        .rx_clk(clk_100),
        .rx_rst_b(rst_b_100),
        .rx_pulse(pulse_out_1)
    );

    async_pulse_sync
    u_async_pulse_sync_fast2slow(
        .tx_clk(clk_100),
        .tx_rst_b(rst_b_100),
        .tx_pulse(pulse_in_2),
        .rx_clk(clk_50),
        .rx_rst_b(rst_b_50),
        .rx_pulse(pulse_out_2)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end


endmodule