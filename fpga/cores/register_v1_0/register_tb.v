`timescale 1 ns / 1 ps

module latch_tb();
  
  parameter WIDTH = 8;
  parameter CLK_PERIOD = 8;

  reg                          clk;
  reg                          en;
  reg [WIDTH-1:0] din;
  wire[WIDTH-1:0]              dout;

  latch #(
    .WIDTH(WIDTH)
    )
  DUT ( //Design Under Test
    .clk(clk),
    .en(en),
    .din(din),
    .dout(dout)
  );

  always #(CLK_PERIOD/2) clk = ~clk;
  
  initial begin
    clk = 1;
    en = 1;
    din = 0;
    #(10*CLK_PERIOD)
    en = 0;
    #(10*CLK_PERIOD)
    din = 1;
    #(10.5*CLK_PERIOD)
    en = 1;
    #(10*CLK_PERIOD)
    $finish;
  end
  
  
endmodule


