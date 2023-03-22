// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/12/2023
// ------------------------------------------------------------------------------------------------
// Serial CRC generator
// Read doc/crc.md to understand the algorithm to calculate the CRC.
// ------------------------------------------------------------------------------------------------

/*
------------------------------------------------------------------------------------------------
CRC generation used Galois LFSR structure
------------------------------------------------------------------------------------------------

Here is an example using the following CRC polynomial
CRC-8: x^8 + x^2 + x + 1
Poly: 0x07

Algorithm #1:
                            shift direction
                            <--------------
      +---+---+---+---+---+---+      +---+      +---+             +------+
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<----(+)<----| data |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |      +------+
        |                         |          |             |
        |                         |          |             |
        +-------------------------+----------+------------->

 (+) means XOR.

1.The incoming data is XOR-ed with the initial values of the polynomial. If the data length is larger then the
  polynomial, then the upper portion are XOR-ed with the initial values of the polynomials.
2.Then the XOR-ed data is loaded into the LFSR as the initial value. The rest of the data that are not loaded
  into the LFSR will be shifted into the LFSR each clock cycle. If there is no more data left, then shift 0 into LFSR.
3.Following the LFSR structure, shift the LFSR and the remaining data for N cycle. N is the size of data bits.
4.When the shifting is done, the bits in LFSR register represent the CRC value of the data.

Algorithm #2:
                            shift direction
                            <--------------
                                                                  +------+
        >------------------------------------------------>(+)<----| data |
        |                                                  |      +------+
        |                         +----------+-------------|
        |                         |          |             |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<-----+
      +---+---+---+---+---+---+      +---+      +---+

1.The initial value of the polynomial is loaded in the the LFSR register, and the incoming data is stored in the data register.
2.In each clock cycle, the MSB of the LFSR is XOR-ed with the MSB of the data, and this bit is loaded into LSB.
  The output of the tapped bit is XOR-ed with this XOR-ed bit before shifting into next position.
3.Following the LFSR structure, shift the LFSR and the data for N cycle till the all the data is shifted into the LFSR.
  (N is the size of data bits.)
4. When the shifting is done, the bits in LFSR register represent the CRC value of the data.

*/

module crc_gen_s #(
    parameter DW = 8,           // data width, data width
    parameter CW = 8,           // crc width
    parameter POLY = 8'h07,     // polynomial represented using normal form.
                                // default is CRC8-CCITT, 8'h01 => x^8 + x^2 + x + 1
    parameter [CW-1:0] INIT = 0 // initial value for the internal LFSR
) (
    input  logic            clk,
    input  logic            rst_b,

    input  logic [DW-1:0]   din,    // data for crc calculation
    input  logic            req,    // request to generate crc

    output logic            ready,  // generator is ready to take new data
    output logic            valid,  // crc generation is done.
    output logic [CW-1:0]   crc     // generated crc
);

    localparam ALGORITHM = 2;

    generate

    if (ALGORITHM == 1) begin: algorithm_1
        localparam CNT_WIDTH = $clog2(DW);
        localparam REM_WIDTH = (DW > CW) ? (DW - CW) : 1;   // remaining data width

        logic                   take_req;   // take the new request
        logic                   calc_done;  // calculation done
        logic                   lfsr_en;
        logic [CW-1:0]          lfsr_in;
        logic [REM_WIDTH-1:0]   data_remaining;

        logic [CNT_WIDTH:0]     counter;    // counter to count on the number of bits calculated

        /////////////////////////////////
        // flow control
        /////////////////////////////////

        assign take_req = req & ready;
        assign calc_done = counter == 0;
        assign valid = calc_done & ~ready;
        assign lfsr_en = take_req | ~calc_done;

        always @(posedge clk or negedge rst_b) begin
            if (!rst_b) begin
                ready <= 1'b1;
            end
            else begin
                if (take_req) begin
                    ready <= 1'b0;
                end
                else if (calc_done) begin
                    ready <= 1'b1;
                end
            end
        end

        always @(posedge clk) begin
            if (!rst_b) begin
                counter <= 0;
            end
            else begin
                if (take_req) begin
                    counter <= DW;
                end
                // only do this when generator is running
                else if (!ready) begin
                    counter <= counter - 1'b1;
                end
            end
        end

        /////////////////////////////////
        // LFSR to calculate crc
        /////////////////////////////////

        // Taking care of the input data
        // Based on our Galois LFSR structure, the LFSR initial value should be din[upper CW width] ^ crc_in
        if (DW > CW) begin
            assign lfsr_in = din[DW-1:DW-CW] ^ INIT;
            always @(posedge clk or rst_b) begin
                if (!rst_b) begin
                    data_remaining <= 0;
                end
                else begin
                    if (take_req) begin
                        data_remaining <=  din[DW-CW-1:0];
                    end
                    else if (!ready) begin
                        data_remaining <= data_remaining << 1;
                    end
                end
            end
        end
        else if (DW == CW) begin
            assign lfsr_in = din ^ INIT;
            assign data_remaining = 1'b0;
        end
        else if (DW < CW) begin
            assign lfsr_in = {din, {(CW-DW){1'b0}}} ^ INIT;
            assign data_remaining = 1'b0;
        end


        // instantiate the LFSR module
        lfsr_galois_s #(
            .DIR("MSB"),
            .WIDTH(CW),
            .POLY(POLY),
            .INIT(INIT)
        )
        u_lfsr_galois_s (
            .clk(clk),
            .rst_b(rst_b),
            .load(take_req),
            .shift_en(lfsr_en),
            .lfsr_in(lfsr_in),
            .din(data_remaining[REM_WIDTH-1]),
            .lfsr_out(crc)
        );

    end: algorithm_1
    if (ALGORITHM == 2) begin: algorithm_2

        localparam CNT_WIDTH = $clog2(DW);  // counter width

        logic                   take_req;   // take the new request
        logic                   calc_done;  // calculation done
        logic                   running;
        logic                   xor_bit;

        logic [DW-1:0]          data;
        logic [CNT_WIDTH:0]     counter;    // counter to count on the number of bits calculated
        logic [CW-1:0]          lfsr;       // lfsr register


        /////////////////////////////////
        // flow control
        /////////////////////////////////

        assign take_req = req & ready;
        assign calc_done = counter == 0;
        assign running = ~ready;
        assign valid = calc_done & running;

        assign xor_bit = data[DW-1] ^ lfsr[CW-1];

        always @(posedge clk or negedge rst_b) begin
            if (!rst_b) begin
                ready <= 1'b1;
                counter <= 0;
                data <= 0;
            end
            else begin
                if (take_req) begin
                    ready <= 1'b0;
                    counter <= DW;
                    data <= din;
                end
                else begin
                    if (calc_done) ready <= 1'b1;
                    if (running) counter <= counter - 1'b1;
                    if (running) data <= data << 1'b1;
                end
            end
        end

        /////////////////////////////////
        // LFSR to calculate crc
        /////////////////////////////////

        always @(posedge clk or negedge rst_b) begin
            if (!rst_b) begin
                lfsr <= INIT;
            end
            else begin
                if (take_req) begin
                    lfsr <= INIT;
                end
                else if (running) begin
                    // Here we don't need to shift the POLY because we are taking the output of the tapped
                    // bit for the xoring.
                    lfsr <= (lfsr << 1) ^ (POLY & {CW{xor_bit}});
                end
            end
        end

        assign crc = lfsr;

    end: algorithm_2
    endgenerate

endmodule
