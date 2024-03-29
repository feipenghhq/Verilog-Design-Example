// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/01/2023
// ------------------------------------------------------------------------------------------------
// Fibonacci LFSR
// ------------------------------------------------------------------------------------------------

/* Design Notes:
----------------------------------
--- LFSR example and structure ---
----------------------------------
Fibonacci LFSR with polynomial: x^16 + x^14 + x^13 + x^11 + 1
Polynomial = 0x6801 = 16'b0110_1000_0000_0001

Shifting towards MSB:

                        shift direction                                  din
                        <--------------                                   |
    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+     |
    | 16| 15| 14| 13| 12| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |<---(+)
    +-+-+---+-+-+-+-+---+-+-+---+---+---+---+---+---+---+---+---+---+     |
      |       |   |       |                                               |
      |       |   |       |                                               |
     (+)-----(+)-(+)-----(+)---------------------------------------------->

Shifting towards LSB:

    din                        shift direction
     |                         -------------->
     |     +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    (+)--->| 16| 15| 14| 13| 12| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
     |     +---+---+-+-+-+-+---+-+-+---+---+---+---+---+---+---+---+---+---+
     |               |   |       |                                       |
     |               |   |       |                                       |
     <--------------(+)-(+)-----(+)-------------------------------------(+)

------------------------------------------
--- Feedback polynomial represnetation ---
------------------------------------------
The feedback polynomial starts at term x^0
The highest order term x^n is ingored since it is always 1
Example: 16'h6801 => x^16 + x^14 + x^13 + x^11 + 1
*/

module lfsr_fib_s #(
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

    logic tap;          // tap bit before xoring with din
    logic tap_data;     // tap bit after xoring with din

    // lfsr register
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            lfsr_out <= INIT;
        end
        else begin
            if (load) begin
                lfsr_out  <= lfsr_in;
            end
            else if (shift_en) begin
                if (DIR == "MSB") begin: shift_msb
                    lfsr_out <= {lfsr_out[WIDTH-2:0], tap_data};
                end
                if (DIR == "LSB") begin: shift_lsb
                    lfsr_out <= {tap_data, lfsr_out[WIDTH-1:1]};
                end
            end
        end
    end

    // Generate the tap bits
    // In general we can AND the lfsr register with the POLY to get the bits that is part of the
    // xor. However, because our POLY representation start from the term 1*x^0, we need to right shift the POLY
    // by 1 so that the tap bits are in the correct locations.
    // The "one" in the polynomial does not correspond to a tap – it corresponds to the input to the first bit
    always @(*) begin
        // Shift towards LSB:

        if (DIR == "LSB") begin
            // lsb is not part of the AND result here so we need to xor with it explicitly
            tap = ^(lfsr_out & (POLY >> 1)) ^ lfsr_out[0];
            tap_data = din ^ tap;
        end

        // Shift towards MSB:
        if (DIR == "MSB") begin
            // msb is not part of the AND result here so we need to xor with it explicitly
            tap = (^(lfsr_out & (POLY >> 1))) ^ lfsr_out[WIDTH-1];
            tap_data = din ^ tap;
        end
    end

endmodule
