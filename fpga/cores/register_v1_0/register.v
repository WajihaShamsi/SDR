`timescale 1 ns / 1 ps

module latch #
(
  parameter integer WIDTH = 32
)
(
  input  wire                          clk,
  input  wire                           en,
  input  wire [WIDTH-1:0]               din,
  output reg  [WIDTH-1:0]              dout
);

  always @(posedge clk) begin 
     if (en)
        dout = din;
  end

endmodule


