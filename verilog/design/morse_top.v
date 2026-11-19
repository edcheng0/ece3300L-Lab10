`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: morse_top   (FPGA top for Part 2, Nexys A7 / Nexys 4 DDR, 100 MHz)
//   BTNC  -> button (sync + 20 ms debounce) -> morse_app.b
//   Digits 1-5 (AN0..AN4): shift register, newest bit on AN0, oldest on AN4
//   Digit 8   (AN7)      : counter value (0..5)
//   AN5, AN6 are blank.
//   Reset: CPU_RESETN (active low red button)
//   LEDs: LED0 = dot, LED1 = dash, LED2 = lg, LED3 = wg (stretched so you can see them)
//////////////////////////////////////////////////////////////////////////////////

module morse_top(
    input         CLK100MHZ,
    input         CPU_RESETN,
    input         BTNC,
    output [6:0]  seg,
    output        dp,
    output [7:0]  an,
    output [3:0]  LED
    );

    wire reset_n = CPU_RESETN;
    wire b;                 // debounced button level
    wire dot, dash, lg, wg;
    wire [4:0] text;
    wire [2:0] count;

    // synchronizer -> debouncer -> edge detector from earlier labs
    button BTN0 (
        .clk(CLK100MHZ), .reset_n(reset_n),
        .noisy(BTNC), .debounced(b),
        .p_edge(), .n_edge(), ._edge()
    );

    morse_app #(.UNIT_CYCLES(5_000_000)) APP0 (     // 50 ms per unit
        .clk(CLK100MHZ), .reset_n(reset_n), .b(b),
        .dot(dot), .dash(dash), .lg(lg), .wg(wg),
        .text(text), .count(count)
    );

    // digit k occupies digits[4k +: 4]
    wire [31:0] digits = { 1'b0, count,          // digit 7 (AN7): counter
                           4'h0, 4'h0,           // digits 6, 5 (blank)
                           3'b000, text[4],      // digit 4
                           3'b000, text[3],      // digit 3
                           3'b000, text[2],      // digit 2
                           3'b000, text[1],      // digit 1
                           3'b000, text[0] };    // digit 0
    wire [7:0] blank = 8'b0110_0000;

    seven_seg_driver SSD0 (
        .clk(CLK100MHZ), .reset_n(reset_n),
        .digits(digits), .blank(blank),
        .seg(seg), .an(an)
    );

    assign dp = 1'b1;       // decimal points off

    // stretch the one-cycle pulses (~84 ms) so the LEDs are visible
    reg [22:0] s_dot, s_dash, s_lg, s_wg;
    always @(posedge CLK100MHZ, negedge reset_n)
        if (~reset_n) begin s_dot <= 0; s_dash <= 0; s_lg <= 0; s_wg <= 0; end
        else begin
            s_dot  <= dot  ? {23{1'b1}} : (s_dot  != 0 ? s_dot  - 1 : 0);
            s_dash <= dash ? {23{1'b1}} : (s_dash != 0 ? s_dash - 1 : 0);
            s_lg   <= lg   ? {23{1'b1}} : (s_lg   != 0 ? s_lg   - 1 : 0);
            s_wg   <= wg   ? {23{1'b1}} : (s_wg   != 0 ? s_wg   - 1 : 0);
        end
    assign LED = {s_wg != 0, s_lg != 0, s_dash != 0, s_dot != 0};
endmodule
