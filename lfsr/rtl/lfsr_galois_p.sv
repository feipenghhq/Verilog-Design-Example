// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/15/2023
// ------------------------------------------------------------------------------------------------
// Parallel Galois LFSR
// ------------------------------------------------------------------------------------------------

/* Design Notes:
------------------------------
* A note about parallel LFSR *
------------------------------
In real digital design, we usually process data in chucks such as 32 bits instead of bit by bit
for example in CRC calculation. If we use serial LFSR then it will take 32 cycles to calculate the
CRC which is not feasible as the latency will be to large.

Instead, we usually use parallel LFSR to generate the LFSR value D_WIDTH cycle later.

The idea of calculaing parallel galois LFSR is similar to "loop unrolling".
We calculate the LFSR for the next D_WIDTH cycle by iterate over LFSR register D_WIDTH times.

------------------------------
* LFSR example and structure *
------------------------------
Fibonacci LFSR with polynomial: x^16 + x^14 + x^13 + x^11 + 1
Polynomial = 0x6801 = 16'b0110_1000_0000_0001

Shifting towards LSB:
                                            shift direction
      din                                    ------------->
bit:   |      15  14         13         12  11         10   9   8   7   6   5   4   3  2   1   0
       |    +---+---+      +---+      +---+---+      +---+---+---+---+---+---+---+---+---+---+---+
      (+)-->| 16| 15|-(+)->| 14|-(+)->| 13| 12|-(+)->| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
       |    +---+---+  |   +---+  |   +---+---+  |   +---+---+---+---+---+---+---+---+---+---+---+
       |               |          |              |                                             |
       |               |          |              |                                             |
       <---------------<----------<--------------<---------------------------------------------+

Data going into the tapped bit in the polynomial is xor-ed before going into the tapped bit.

Shifting towards MSB:
                                    shift direction
                                    <--------------                                           din
bit: 15  14         13         12  11         10   9   8   7   6   5   4   3  2   1   0        |
    +---+---+      +---+      +---+---+      +---+---+---+---+---+---+---+---+---+---+---+     |
    | 16| 15|<-(+)-| 14|<-(+)-| 13| 12|<-(+)-| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |<---(+)
    +---+---+   |  +---+   |  +---+---+   |  +---+---+---+---+---+---+---+---+---+---+---+     |
      |         |          |              |                                                    |
      |         |          |              |                                                    |
      +>-------->---------->-------------->---------------------------------------------------->

Note: shifting toward MSB is a bit different from shifting toward LSB.
The data going out of the tap bit is xored before sending to the next bit

--------------------------------------
* Feedback polynomial represnetation *
--------------------------------------
The feedback polynomial starts at term x^0
The highest order term x^n is ingored since it is always 1
Example: 16'h6801 => x^16 + x^14 + x^13 + x^11 + 1
*/

module lfsr_galois_p #(
    parameter D_WIDTH = 16,     // Number of cycle we want to calculate, also is data width
    parameter WIDTH = 16,       // Width of the LFSR
    parameter DIR = "MSB",      // Direction of the LFSR shifting, MSB shift towards MSB, LSB shift towards LSB
    parameter POLY = 16'h6801   // Feedback polynomial.
) (
    input  logic [WIDTH-1:0]    lfsr_in,    // kfsr initial value
    input  logic [D_WIDTH-1:0]  data,       // data input, MSB is calculated first
    output logic [WIDTH-1:0]    lfsr_out    // lfsr output
);

    // Big array to capture the LFSR value for each iteration
    // Only this style works with Yosys
    logic [WIDTH-1:0] lfsr_state[D_WIDTH:0];

    // iteration to calculate the LFSR after D_WIDTH cycle
    genvar i;
    generate
        assign lfsr_state[0] = lfsr_in;
        for (i = 1; i <= D_WIDTH; i = i + 1) begin
            assign lfsr_state[i] = next_lfsr(lfsr_state[i-1], data[D_WIDTH-i]);
        end
    endgenerate

    assign lfsr_out = lfsr_state[D_WIDTH];

    // Function used to calculte the next lfsr value.
    // Same algorithm used in lfsr_galois
    function automatic [WIDTH-1:0] next_lfsr;
        input [WIDTH-1:0] lfsr_input;
        input             data_input;
        if (DIR == "LSB") begin: shift_lsb
            if (lfsr_input[0]) begin
                next_lfsr = {data_input, {lfsr_input[WIDTH-1:1]}} ^ (POLY >> 1);
            end
            else begin
                next_lfsr = {data_input, {lfsr_input[WIDTH-1:1]}};
            end
        end
        if (DIR == "MSB") begin: shift_msb
            if (lfsr_input[WIDTH-1]) begin
                next_lfsr = {{lfsr_input[WIDTH-2:0]}, data_input} ^ POLY;
            end
            else begin
                next_lfsr = {{lfsr_input[WIDTH-2:0]}, data_input};
            end
        end
    endfunction

endmodule