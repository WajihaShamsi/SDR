`timescale 1ns / 1ps

module delay_tb();

parameter WIDTH = 8;
parameter CLK_PERIOD = 8;

reg clk;
reg [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;

delay #(
    .WIDTH(WIDTH)
)
DUT (
    .clk(clk),
    .din(din),
    .dout(dout)
);

always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    clk = 0;
    din = 0;

    #(10*CLK_PERIOD);
    din = 8'h01;

    #(10*CLK_PERIOD);
    din = 8'h00;

    #(10*CLK_PERIOD);
    din = 8'h01;

    #(10*CLK_PERIOD);
    $finish;
end

endmodule