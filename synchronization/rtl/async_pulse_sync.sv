// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/13/2023
// ------------------------------------------------------------------------------------------------
// Pluse synchronization
// ------------------------------------------------------------------------------------------------

/*
Synchronize pulse from TX clock domain to RX clock domain.
We extend the pulse signal to level signal and then pass the level signal across the clock domain.
On TX side, whenever a new pulse arrives, the level signal will be inverted.
On RX side, whenever the level signal is changed, then a new pulse is generated.

There need to be sufficient gaps between the two pulse, because the RX clock domain needs to use double flop
synrhonizer to sample the data change from TX clock domain. If the gap between the two pulse is too small,
then the RX domain may not be able to sample the data change.The minimum interval between the two pulse should
be 2 RX clock cycles.

*/

module async_pulse_sync (
    // TX clock domain
    input  tx_clk,
    input  tx_rst_b,
    input  tx_pulse,

    // RX clock domain
    input  rx_clk,
    input  rx_rst_b,
    output rx_pulse
);

    logic           level_tx;

    logic [1:0]     level_tx_doublesync;
    logic           level_rx;
    logic           level_rx_delay;

    // TX clock domain
    always @(posedge tx_clk or negedge tx_rst_b) begin
        if (!tx_rst_b) level_tx <= 1'b0;
        else if (tx_pulse) level_tx <= ~level_tx;
    end

    // Clock crossing
    always @(posedge rx_clk or negedge rx_rst_b) begin
        if (!rx_rst_b) begin
            level_tx_doublesync <= 2'b0;
        end
        else begin
            level_tx_doublesync[0] <= level_tx;
            level_tx_doublesync[1] <= level_tx_doublesync[0];
        end
    end

    // RX clock domain
    assign level_rx = level_tx_doublesync[1];
    always @(posedge rx_clk or negedge rx_rst_b) begin
        if (!rx_rst_b) level_rx_delay <= 1'b0;
        else level_rx_delay <= level_rx;
    end

    assign rx_pulse = level_rx_delay ^ level_rx;

endmodule