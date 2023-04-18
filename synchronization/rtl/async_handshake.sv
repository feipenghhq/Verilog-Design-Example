// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/13/2023
// ------------------------------------------------------------------------------------------------
// Clock domain crossing using full handshake
// ------------------------------------------------------------------------------------------------

module async_handshake #(
    parameter WIDTH = 8
)(
    // TX clock domain
    input  logic                tx_clk,
    input  logic                tx_rst_b,
    input  logic [WIDTH-1:0]    tx_data,
    input  logic                tx_valid,
    output logic                tx_ready,

    // RX clock domain
    input  logic                rx_clk,
    input  logic                rx_rst_b,
    output logic [WIDTH-1:0]    rx_data,
    output logic                rx_valid

);

    typedef enum logic [1:0] {
        TX_IDLE    = 2'b00,
        TX_REQ     = 2'b01,
        TX_ACK     = 2'b10
    } state_tx_t;

    typedef enum logic {
        RX_IDLE    = 1'b0,
        RX_ACK     = 1'b1
    } state_rx_t;

    logic               tx_req;
    state_tx_t          state_tx;
    logic [WIDTH-1:0]   tx_data_int;
    logic [1:0]         rx_ack_doublesync;
    logic               rx_ack_tx_clk;

    logic               rx_ack;
    state_rx_t          state_rx;
    logic [1:0]         tx_req_doublesync;
    logic               tx_req_rx_clk;

    //////////////////////////////
    // TX logic
    //////////////////////////////

    // state machine
    always @(posedge tx_clk or negedge tx_rst_b) begin
        if (!tx_rst_b) begin
            tx_req <= 1'b0;
            tx_ready <= 1'b0;
            state_tx <= TX_IDLE;
        end
        else begin
            tx_req <= 1'b0;
            tx_ready <= 1'b1;
            case(state_tx)
                TX_IDLE: begin
                    if (tx_valid) begin
                        state_tx <= TX_REQ;
                        tx_req <= 1'b1;
                        tx_ready <= 1'b0;
                        tx_data_int <= tx_data;
                    end
                end
                TX_REQ: begin
                    tx_req <= 1'b1;
                    tx_ready <= 1'b0;
                    if (rx_ack_tx_clk) begin
                        state_tx <= TX_ACK;
                        tx_req <= 1'b0;
                    end
                end
                TX_ACK: begin
                    tx_ready <= 1'b0;
                    if (!rx_ack_tx_clk) begin
                        state_tx <= TX_IDLE;
                        tx_ready <= 1'b1;
                    end
                end
                default: state_tx <= TX_IDLE;
            endcase
        end
    end

    // synchronize the ack signal from rx clock domain
    always @(posedge tx_clk or negedge tx_rst_b) begin
        if (!tx_rst_b) begin
            rx_ack_doublesync <= 0;
        end
        else begin
            rx_ack_doublesync[0] <= rx_ack;
            rx_ack_doublesync[1] <= rx_ack_doublesync[0];
        end
    end

    assign rx_ack_tx_clk = rx_ack_doublesync[1];

    //////////////////////////////
    // RX logic
    //////////////////////////////

    // state machine
    always @(posedge rx_clk or negedge rx_rst_b) begin
        if (!rx_rst_b) begin
            rx_ack <= 1'b0;
            rx_valid <= 1'b0;
            state_rx <= RX_IDLE;
        end
        else begin
            rx_ack <= 1'b0;
            rx_valid <= 1'b0;
            case(state_rx)
                RX_IDLE: begin
                    if (tx_req_rx_clk) begin
                        state_rx <= RX_ACK;
                        rx_ack <= 1'b1;
                        rx_valid <= 1'b1;
                    end
                end
                RX_ACK: begin
                    rx_ack <= 1'b1;
                    if (!tx_req_rx_clk) begin
                        state_rx <= RX_IDLE;
                        rx_ack <= 1'b0;
                    end
                end
                default: state_rx <= RX_IDLE;
            endcase
        end
    end

    // synchronize the req signal from tx clock domain
    always @(posedge rx_clk or negedge rx_rst_b) begin
        if (!rx_rst_b) begin
            tx_req_doublesync <= 0;
        end
        else begin
            tx_req_doublesync[0] <= tx_req;
            tx_req_doublesync[1] <= tx_req_doublesync[0];
        end
    end

    assign tx_req_rx_clk = tx_req_doublesync[1];

    assign rx_data = tx_data_int;

endmodule