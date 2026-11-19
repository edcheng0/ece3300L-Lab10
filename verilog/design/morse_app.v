`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: morse_app
// Description: Part 2 circuit, built exactly as in the lab figure (no FPGA pins here).
//
//   b --> morse_decoder --> dot, dash, lg, wg
//   shift = dot ^ dash                 (one pulse per dit/dash)
//   5-bit shift register: shift enable = shift, SI = dash  (dot -> 0, dash -> 1)
//   3-bit UDL counter   : En = shift, up = 1, D = 0, load = (Q == 5)
//                         counts dits/dashes 1..5, then loads 0 on the next one
//////////////////////////////////////////////////////////////////////////////////

module morse_app
    #(parameter UNIT_CYCLES = 5_000_000)(
    input        clk,
    input        reset_n,
    input        b,              // debounced button (or testbench stimulus)
    output       dot, dash, lg, wg,
    output [4:0] text,           // shift register contents
    output [2:0] count           // number of dits/dashes shifted in
    );

    wire shift = dot ^ dash;

    morse_decoder #(.UNIT_CYCLES(UNIT_CYCLES)) MD0 (
        .clk(clk), .reset_n(reset_n), .b(b),
        .dot(dot), .dash(dash), .lg(lg), .wg(wg)
    );

    shift_register #(.BITS(5)) SR0 (
        .clk(clk), .reset_n(reset_n),
        .shift(shift), .SI(dash),
        .Q(text)
    );

    udl_counter #(.BITS(3)) C0 (
        .clk(clk), .reset_n(reset_n),
        .enable(shift),
        .up(1'b1),
        .load(count == 3'd5),
        .D(3'd0),
        .Q(count)
    );
endmodule
