`timescale 1 ns / 1 ps

module latch_tb();
  
  parameter WIDTH = 8;

  reg                          clk;
  reg                          en;
  reg                          rst;
  reg [WIDTH-1:0] din;
  wire[WIDTH-1:0]              dout;

  latch #(
    .WIDTH(WIDTH)
    )
  DUT ( //Design Under Test
    .clk(clk),
    .en(en),
    .din(din),
    .rst(rst),
    .dout(dout)
  );

  parameter CLK_PERIOD = 8;

  initial begin
    clk = 1;
    en = 1;
    rst = 0;
    din = 0;
    #(10*CLK_PERIOD)
    en = 0;
    #(10*CLK_PERIOD)
    din = 1;
    #(10*CLK_PERIOD)
    en = 1;
    #(10*CLK_PERIOD)
    rst = 1;
    #(10*CLK_PERIOD)
    $finish;
  end
  
  //always #(CLK_PERIOD/2) clk = ~clk;
  
endmodule


