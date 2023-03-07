// ------------------------------------------------------------------------------------------------
// Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
// ------------------------------------------------------------------------------------------------
// Author: Heqing Huang
// Date Created: 03/03/2023
// ------------------------------------------------------------------------------------------------
// An example 8 bit scrambler
// ------------------------------------------------------------------------------------------------
// Example taken from the book <Advanced Chip Design Practical Examples in Verilog>
// Chapter 6.2.7 PCIe Scrambler
//
// Features:
//      - 8 bit scrambler, the data input and output are 8 bit wide
//      - The LFSR polynomial is X^16 + X^5 + X^4 + X^3 + 1
//      - The LFSR is initialized to 16'hFFFF
//      - COM character that initialize LFSR is 8'hBC
//      - The SKIP character is 8'h1C
// ------------------------------------------------------------------------------------------------

module scrambler_8bit (

);



endmodule