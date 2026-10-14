`timescale 1ns / 1ps

module delay #
(
    parameter integer WIDTH = 32
)
(
    input wire                  clk,
    input wire [WIDTH-1:0]      din,
    output reg [WIDTH-1:0]      dout
);

always @(posedge clk)
begin
    dout <= din;
end

endmodule