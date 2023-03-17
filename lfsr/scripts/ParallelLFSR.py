#!/usr/bin/python3
"""
------------------------------------------------------------------------------------------------
Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
------------------------------------------------------------------------------------------------
Author: Heqing Huang
Date Created: 03/15/2023
------------------------------------------------------------------------------------------------
Python script to generate a specific parallel Galois LFSR
jinja is required to generate verilog
https://github.com/pallets/jinja
------------------------------------------------------------------------------------------------
Example:
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

(pic generated by https://textik.com/)
------------------------------------------------------------------------------------------------
"""

from jinja2 import Template
import argparse

class Entry():

    def __init__(self, idx):
        """ Create a new entry """
        self.idx = idx
        self.lfsr = [idx]
        self.data = []
        self.lfsr_next = []
        self.data_next = []

    def xor(self, a, b):
        """ xor this entry with another entry """
        def _xor_list(x, y):
            xs = set(x)
            ys = set(y)
            return list(xs ^ ys)

        self.lfsr_next = _xor_list(a.lfsr, b.lfsr)
        self.data_next = _xor_list(a.data, b.data)

    def xor_data(self, other, data):
        self.lfsr_next = list(other.lfsr)
        self.data_next = list(other.data)
        self.data_next.append(data)

    def shift(self, other):
        """ Shifted from another entry """
        self.lfsr_next = list(other.lfsr)
        self.data_next = list(other.data)

    def update(self):
        """ update the entry """
        self.lfsr = self.lfsr_next
        self.data = self.data_next

    def __str__(self):
        string = f"lfsr_out[{self.idx}] = "
        for i in range(len(self.lfsr)):
            if i != 0:
                string += " ^ "
            string += f"lfsr_in[{self.lfsr[i]}]"
        for i in range(len(self.data)):
            string += f" ^ data[{self.data[i]}]"
        return string

class ParallelLFSR():

    def __init__(self, width, poly, direction="MSB", N=0):
        """
        @param width: LFSR width
        @param poly: LFSR polynomial
        @param N: number of cycle or input data width. 0 means no input data
        """
        self.lfsr = []
        self.N = N
        self.width = width
        self.poly = poly
        self.direction = direction
        self.iter = 0
        # create entry for each bit position
        for i in range(width):
            self.lfsr.append(Entry(i))

    def _next_msb(self):
        """
        generate the next LFSR when shifting toward MSB
        """
        self.iter += 1
        for i in range(1, self.width):
            # if tap is one, then we need to xor the MSB with the previous entry
            if (self.poly >> i) & 0x1:
                self.lfsr[i].xor(self.lfsr[i-1], self.lfsr[self.width-1])
            # else, the entry from previous bit is shifted to this bit
            else:
                self.lfsr[i].shift(self.lfsr[i-1])
            # the LSB gets the msb and the data input. MSB of data is shifted in first
        if self.N == 0: # no data
            self.lfsr[0].shift(self.lfsr[self.width-1])
        else:           # has data
            self.lfsr[0].xor_data(self.lfsr[self.width-1], (self.N)-self.iter)

        # update all the entries
        for entry in self.lfsr:
            entry.update()


    def equation(self, n):
        """
            generate parallel LFSR calculation equation
        """
        if self.direction == "MSB":
            for _ in range(n):
                self._next_msb()
        else:
            print(f"ERROR: Direction {direction} not supported!")

    def __str__(self):
        string = ""
        for entry in self.lfsr:
            string += (str(entry) + "\n")
        return string

    def verilog(self, n, name=None, output=None):
        """
        generate verilog code to calculate LFSR after n cycle
        """
        self.equation(n)
        if not name:
            name = f"lfsr_{hex(self.poly)}_W{self.width}_D{self.N}"
        if not output:
            output = f"{name}.sv"
        print("Opening file '%s'..." % output)
        output_file = open(output, 'w')
        verilog_code = ""
        for entry in self.lfsr:
            verilog_code += "assign " + str(entry) + ";\n"

        output_file.write(t.render(
                poly=hex(self.poly),
                width=self.width,
                N = self.N,
                name=name,
                verilog_code=verilog_code))

        print("Done!")

t = Template(u"""
// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Generated by ParallelLFSR.py
// ------------------------------------------------------------------------------------------------
// Polynomial: {{poly}}
// LFSR width: {{width}}
// Data width: {{N}}
// ------------------------------------------------------------------------------------------------

module {{name}}  (
    input  logic [{{width}}-1:0]    lfsr_in,
    {%- if N > 0 %}
    input  logic [{{N}}-1:0]        data,
    {%- endif %}
    output logic [{{width}}-1:0]    lfsr_out
);

{{verilog_code}}

endmodule
""")

def test():
    lfsr = ParallelLFSR(16, 0x6801)
    lfsr.verilog(16)


def main():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('-w', '--width',     type=int, default=16,       help="width of Polynomial (default 16)")
    parser.add_argument('-d', '--datawidth', type=int, default=0,        help="width of input data bus (default 16). 0 means no input data used.")
    parser.add_argument('-p', '--poly',      type=str, default='0x6801', help="LFSR polynomial (default 0x6801)")
    parser.add_argument('-c', '--config',    type=str, default='galois',
                                choices=['galois', 'fibonacci'],         help="LFSR configuration (default galois)")
    parser.add_argument('-dir', '--direction',  type=str, default='MSB',
                                choices=['MSB', 'LSB'],                  help="LFSR shift direction (default MSB)")
    parser.add_argument('-n', '--name',      type=str,                   help="module name")
    parser.add_argument('-o', '--output',    type=str,                   help="output file name")
    args = parser.parse_args()

    lfsr = ParallelLFSR(int(args.width), int(args.poly, 16), args.direction, int(args.datawidth))
    lfsr.verilog(int(args.datawidth), args.name, args.output)

if __name__ == "__main__":
    #test()
    main()