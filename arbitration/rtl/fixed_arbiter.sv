// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 05/01/2023
// ------------------------------------------------------------------------------------------------
// Fixed priority arbiter
// ------------------------------------------------------------------------------------------------

/*
Note: A base signal is given to identify which bit has the highest priority.
For example, in the following bit pattern:
Bit position  7 6 5 4 3 2 1 0
base:         0 0 0 0 1 0 0 0
Priority: 3 > 4 > 5 > 6 > 7 > 0 > 1 > 2
*/

module fixed_arbiter #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0]              req,    // request vector
    input  [WIDTH-1:0]              base,   // a one-hot signal indicating which bit has the highest priority
    output [WIDTH-1:0]              grant   // grant vector
);

    logic [WIDTH*2-1:0]             double_req;
    logic [WIDTH*2-1:0]             double_grant;
    logic [WIDTH*2-1:0]             extended_base;

    assign double_req = {req, req};
    assign extended_base = {{WIDTH{1'b0}}, base};
    assign double_grant = double_req & (~double_req + extended_base);
    assign grant = double_grant[WIDTH*2-1:WIDTH] | double_grant[WIDTH-1:0];

endmodule
