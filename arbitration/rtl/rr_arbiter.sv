// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 05/01/2023
// ------------------------------------------------------------------------------------------------
// Round Robin Arbiter
// A good reference about designing Round Robin Arbiter can be found here:
// Arbiters: Design Ideas and Coding Styles
// https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.86.550&rep=rep1&type=pdf
// ------------------------------------------------------------------------------------------------

/*
In this round robin arbiter design, we store the last granted value as the new base for the next
round of arbitration.
*/

module rr_arbiter #(
    parameter WIDTH = 8
) (
    input                           clk,
    input                           rst_b,
    input  [WIDTH-1:0]              req,    // request vector
    output [WIDTH-1:0]              grant   // grant vector
);

    logic [WIDTH-1:0]               base;
    logic [WIDTH*2-1:0]             double_req;
    logic [WIDTH*2-1:0]             double_grant;
    logic [WIDTH*2-1:0]             extended_base;
    logic                           new_req;

    assign new_req = |req;
    assign double_req = {req, req};
    assign extended_base = {{WIDTH{1'b0}}, base};
    assign double_grant = double_req & (~double_req + extended_base);
    assign grant = double_grant[WIDTH*2-1:WIDTH] | double_grant[WIDTH-1:0];

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            base <= 1;
        end
        else if (new_req) begin
            // left shift the grant and rotate it as the new base
            base <= {grant[WIDTH-2:0], grant[WIDTH-1]};
        end
    end

    `ifdef COCOTB_SIM
    //initial begin
    //    $dumpfile("dump.vcd");
    //    $dumpvars(0, rr_arbiter);
    //end
    `endif

endmodule
