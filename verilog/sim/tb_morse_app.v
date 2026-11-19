`timescale 1ns / 1ps
// Simple testbench for morse_app (decoder + shift register + counter)
// 1 unit = 10 clock cycles. dot shifts in 0, dash shifts in 1.
module tb_morse_app;
    reg  clk = 0, reset_n = 0, b = 0;
    wire dot, dash, lg, wg;
    wire [4:0] text;
    wire [2:0] count;

    morse_app #(.UNIT_CYCLES(10)) DUT (
        .clk(clk), .reset_n(reset_n), .b(b),
        .dot(dot), .dash(dash), .lg(lg), .wg(wg),
        .text(text), .count(count)
    );

    always #5 clk = ~clk;

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

    task dit; begin press(1); gap(1); end endtask
    task dah; begin press(3); gap(1); end endtask

    task do_reset;
    begin
        @(negedge clk); reset_n = 0;
        @(negedge clk); reset_n = 1;
    end
    endtask

    // print text and count whenever they change
    initial $monitor("%0t ns: text=%b count=%0d", $time, text, count);

    initial
    begin
        $dumpfile("tb_morse_app.vcd");
        $dumpvars(0, tb_morse_app);
        repeat (3) @(negedge clk);
        reset_n = 1;

        dit; dah; gap(3);                   // A  .-     -> 00001, count 2
        do_reset;
        dah; dit; dah; dit; gap(3);         // C  -.-.   -> 01010, count 4
        do_reset;
        dah; dah; dah; dah; dah; gap(3);    // 0  -----  -> 11111, count 5
        dit; gap(3);                        // 6th symbol: counter reloads to 0
        $finish;
    end
endmodule
