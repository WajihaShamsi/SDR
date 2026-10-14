`timescale 1 ns / 1 ps

module agc_mux_tb();

parameter WIDTH = 16;
parameter CLK_PERIOD = 8;
parameter N_POSITIONS = 16;

reg clk;
reg clken;
reg [31:0]din;
reg [3:0] sel;
wire [WIDTH-1:0] dout;

agc_mux #(
    .WIDTH(WIDTH)
) DUT (
    .din(din),
    .sel(sel),
    .dout(dout),
    .clk(clk),
    .clken(clken)
);

always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    clk = 0;
    clken = 0;
    sel = 0;
    din = 32'b111111111110100101101001100010100;
    #80
    sel = 4'b0000; #80;
    sel = 4'b0001; #80;
    sel = 4'b0010; #80;
    clken = 1;  #80;
    sel = 4'b0011; #80;
    sel = 4'b0100; #80;
    sel = 4'b0101; #80;
    sel = 4'b0110; #80;
    sel = 4'b0111; #80;
    sel = 4'b1000; #80;
    sel = 4'b1001; #80;
    sel = 4'b1010; #80;
    sel = 4'b1111; #80;
    sel = 4'b0000; #80;
    sel = 4'b0001; #80;
    sel = 4'b0010; #80;

    $finish;
end

endmodule