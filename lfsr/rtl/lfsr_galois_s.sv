// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/03/2023
// ------------------------------------------------------------------------------------------------
// Galois LFSR
// ------------------------------------------------------------------------------------------------

/* Design Notes:
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

module lfsr_galois_s #(
    parameter WIDTH = 16,       // Width of the LFSR
    parameter DIR = "MSB",      // Direction of the LFSR shifting, MSB shift towards MSB, LSB shift towards LSB
    parameter POLY = 16'h6801,  // Feedback polynomial.
    parameter INIT = 16'hACE1   // Initial seed for the LFSR.
) (
    input  logic                clk,
    input  logic                rst_b,
    input  logic                load,       // load new values into lfsr
    input  logic                shift_en,   // shift enabled
    input  logic [WIDTH-1:0]    lfsr_in,    // data to be loaded into lfsr
    input  logic                din,        // serial data input to lfsr
    output logic [WIDTH-1:0]    lfsr_out    // lfsr data output
);

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr_out <= INIT;
        end
        else begin
            if (load) begin
                lfsr_out <= lfsr_in;
            end
            else if (shift_en) begin
                if (DIR == "LSB") begin: shift_lsb
                    if (lfsr_out[0]) begin
                        // here we need to right shift the POLY by 1 bit because it start from term x^0
                        // but our LFSR start from term 1
                        lfsr_out <= {din, {lfsr_out[WIDTH-1:1]}} ^ (POLY >> 1);
                    end
                    else begin
                        lfsr_out <= {din, {lfsr_out[WIDTH-1:1]}};
                    end
                end
                if (DIR == "MSB") begin: shift_msb
                    if (lfsr_out[WIDTH-1]) begin
                        // here we don't need to shift the POLY because we are taking the output of the tapped
                        // bit for the xoring.
                        lfsr_out <= {{lfsr_out[WIDTH-2:0]}, din} ^ POLY;
                    end
                    else begin
                        lfsr_out <= {{lfsr_out[WIDTH-2:0]}, din};
                    end
                end
            end
        end
    end


endmodule