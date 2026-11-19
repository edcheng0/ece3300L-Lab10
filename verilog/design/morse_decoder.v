`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: morse_decoder
// Description:
//   Measures how long the (already debounced, synchronous) input b is high/low
//   and produces ONE-clock-cycle pulses:
//
//     dot  : b was high for  < 3 units          (nominal 1 unit)
//     dash : b was high for >= 3 units          (nominal 3 units)
//     lg   : b has been low for 3 units after a symbol  (letter gap)
//     wg   : b has been low for 7 units after a symbol  (word gap)
//
//   dot / dash are issued right after b FALLS (that is when the length is known).
//   lg / wg are issued as soon as the low time reaches 3 / 7 units, so a word gap
//   produces lg first (end of the letter) and then wg (end of the word).
//   No lg/wg is produced after reset until at least one symbol has been seen,
//   and nothing more is produced after the wg of a gap.
//
//   One unit = UNIT_CYCLES clock cycles.
//     50 ms at 100 MHz -> UNIT_CYCLES = 5_000_000 (default)
//   Use a small value (e.g. 10) in simulation. UNIT_CYCLES must be >= 2.
//
//   Structure (the "timer + counter" idea from the hints):
//     tick  : timer, counts clock cycles inside one unit
//     units : counter, counts finished units (saturates at 7)
//     Both restart on every edge of b, so the measurement is exact.
//////////////////////////////////////////////////////////////////////////////////

module morse_decoder
    #(parameter UNIT_CYCLES = 5_000_000)(
    input      clk,
    input      reset_n,
    input      b,
    output reg dot,
    output reg dash,
    output reg lg,
    output reg wg
    );

    localparam TBITS = $clog2(UNIT_CYCLES);

    reg [TBITS-1:0] tick;     // cycles elapsed inside the current unit
    reg [2:0]       units;    // whole units elapsed since last edge of b (saturates at 7)
    reg             b_prev;   // b delayed by one clock -> edge detection
    reg             armed;    // 1 = a symbol was seen and its gap is still being timed

    wire edge_ = b ^ b_prev;                    // b changed this cycle
    wire wrap  = (tick == UNIT_CYCLES - 1);     // last cycle of a unit

    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
        begin
            tick   <= 0;
            units  <= 0;
            b_prev <= 0;
            armed  <= 0;
            dot    <= 0;
            dash   <= 0;
            lg     <= 0;
            wg     <= 0;
        end
        else
        begin
            // pulses default to 0 -> every output is exactly one clock wide
            dot    <= 0;
            dash   <= 0;
            lg     <= 0;
            wg     <= 0;
            b_prev <= b;

            if (edge_)
            begin
                // restart the measurement (this cycle already counts as cycle 1)
                tick  <= 1;
                units <= 0;

                if (~b)                 // falling edge: the press just ended
                begin
                    if (units >= 3) dash <= 1;   // 3 to 7+ units
                    else            dot  <= 1;   // 0 to 2 units
                    armed <= 1;                  // start timing the gap
                end
                else                    // rising edge: gap ended
                    armed <= 0;
            end
            else
            begin
                if (wrap)
                begin
                    tick <= 0;
                    if (units != 7)
                        units <= units + 1;

                    // low time just reached 3 units / 7 units
                    if (~b & armed)
                    begin
                        if (units == 2) lg <= 1;
                        if (units == 6)
                        begin
                            wg    <= 1;
                            armed <= 0;      // word is over, nothing more to report
                        end
                    end
                end
                else
                    tick <= tick + 1;
            end
        end
    end
endmodule
