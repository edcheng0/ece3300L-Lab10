`timescale 1ns / 1ps
// Simple testbench for morse_decoder (1 unit = 10 clock cycles)
module tb_morse_decoder;
    reg  clk = 0, reset_n = 0, b = 0;
    wire dot, dash, lg, wg;

    morse_decoder #(.UNIT_CYCLES(10)) DUT (
        .clk(clk), .reset_n(reset_n), .b(b),
        .dot(dot), .dash(dash), .lg(lg), .wg(wg)
    );

    always #5 clk = ~clk;

    // b high / low for a number of units
    task press(input integer units);
    begin
        @(negedge clk); b = 1;
        repeat (units * 10 - 1) @(negedge clk);
    end
    endtask

    task gap(input integer units);
    begin
        @(negedge clk); b = 0;
        repeat (units * 10 - 1) @(negedge clk);
    end
    endtask

    // print every pulse
    always @(posedge clk)
        if (dot | dash | lg | wg)
            $display("%0t ns: dot=%b dash=%b lg=%b wg=%b", $time, dot, dash, lg, wg);

    initial
    begin
        $dumpfile("tb_morse_decoder.vcd");
        $dumpvars(0, tb_morse_decoder);
        repeat (3) @(negedge clk);
        reset_n = 1;

        press(1); gap(1);       // dot
        press(3); gap(3);       // dash, then letter gap (lg)
        press(1); gap(7);       // dot, then word gap (lg, wg)
        press(2); gap(1);       // 2 units is still a dot
        press(5); gap(5);       // 5 units is still a dash, 5-unit gap is lg only
        gap(5);
        $finish;
    end
endmodule
