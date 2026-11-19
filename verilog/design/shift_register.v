`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: shift_register
// Description: N-bit serial-in shift register with enable (shift) and async reset.
//   On every clock where shift = 1:  Q <= {Q[N-2:0], SI}
//   -> newest bit enters at Q[0], oldest bit sits in Q[N-1].
//////////////////////////////////////////////////////////////////////////////////

module shift_register
    #(parameter BITS = 5)(
    input             clk,
    input             reset_n,
    input             shift,
    input             SI,
    output [BITS-1:0] Q
    );

    reg [BITS-1:0] Q_reg;

    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
            Q_reg <= 'b0;
        else if (shift)
            Q_reg <= {Q_reg[BITS-2:0], SI};
    end

    assign Q = Q_reg;
endmodule
