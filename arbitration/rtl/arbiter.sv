// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 05/01/2023
// ------------------------------------------------------------------------------------------------
// Fixed priority arbiter with lower bit having highest priority
// ------------------------------------------------------------------------------------------------


module arbiter #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0]              req,    // request vector
    output [WIDTH-1:0]              grant   // grant vector
);

    assign grant = req & (~req + 1'b1);

endmodule
