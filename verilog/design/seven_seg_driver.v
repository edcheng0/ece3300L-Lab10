`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seven_seg_driver
// Description: Time-multiplexes 8 seven-segment digits (Nexys A7 / Nexys 4 DDR style,
//   common-anode, active-LOW segments and anodes).
//   digits[4*k +: 4] is the hex value shown on digit k   (digit 0 = AN0 = rightmost)
//   blank[k] = 1 turns digit k off.
//   Refresh: 17-bit free-running counter, top 3 bits pick the digit
//   (about 1.3 ms for a full scan at 100 MHz -> no visible flicker).
//////////////////////////////////////////////////////////////////////////////////

module seven_seg_driver(
    input         clk,
    input         reset_n,
    input  [31:0] digits,
    input  [7:0]  blank,
    output reg [6:0] seg,    // {CG, CF, CE, CD, CC, CB, CA}, active low
    output reg [7:0] an      // AN7..AN0, active low
    );

    reg [16:0] refresh;
    always @(posedge clk, negedge reset_n)
        if (~reset_n) refresh <= 0;
        else          refresh <= refresh + 1;

    wire [2:0] sel = refresh[16:14];

    reg [3:0] hex;
    always @(*)
    begin
        hex = digits[4*sel +: 4];
        an  = 8'hFF;
        if (~blank[sel])
            an[sel] = 1'b0;
    end

    // hex -> segments (active low), bit order {g,f,e,d,c,b,a}
    always @(*)
    begin
        case (hex)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
        endcase
    end
endmodule
