// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 04/12/2023
// ------------------------------------------------------------------------------------------------
// Barrier Shifter
// ------------------------------------------------------------------------------------------------


module barrier_shifter #(
    parameter WIDTH = 8,
    parameter DIRECTION = "L"   // L: rotate left. R: rotate right
) (
    input  [WIDTH-1:0]              din,
    input  [$clog2(WIDTH)-1:0]      shift,
    output [WIDTH-1:0]              dout
);

    logic [$clog2(WIDTH)-1:0][WIDTH-1:0]    shifted_data;

    `define ROTATE_LEFT(data, i)      ({data[WIDTH-(i)-1:0], data[WIDTH-1:WIDTH-(i)]})
    `define ROTATE_RIGHT(data, i)     ({data[(i)-1:0], data[WIDTH-1:i]})
    `define ROTATE(data, i)           ((DIRECTION == "L") ? `ROTATE_LEFT(data, i) : `ROTATE_RIGHT(data, i))

    genvar i;
    generate
        assign shifted_data[0] = shift[0] ? `ROTATE(din, 1) : din;
        for (i = 1; i < $clog2(WIDTH); i = i + 1) begin
            assign shifted_data[i] = shift[i] ? `ROTATE(shifted_data[i-1], 1 << i) : shifted_data[i-1];
        end
    endgenerate

    assign dout = shifted_data[$clog2(WIDTH)-1];

    `undef ROTATE_LEFT
    `undef ROTATE_RIGHT
    `undef ROTATE

endmodule
