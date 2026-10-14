`timescale 1 ns / 1 ps

module agc_mux #(
    parameter integer N_POSITIONS = 16,
    parameter integer SEL_WIDTH   = 4,
    parameter integer WIDTH       = 16
)(
    input  wire clk,
    input  wire clken,
    input  wire [31:0] din,
    input  wire [SEL_WIDTH-1:0] sel,
    output reg [WIDTH-1:0] dout
);

localparam MID = (N_POSITIONS/2)-1;

reg [31:0] Idout;

always @(posedge clk) begin
Idout = 32'b00000000000000000000000000000000;
    if (clken) begin
        if (sel < MID) begin
//            dout <= din[sel+:WIDTH] <<< (MID - sel); //left shifter (amplify)
            dout <= din <<< (MID - sel);
           // dout <= Idout[31:16];
        end
        else if (sel > MID) begin
//            dout <= din[sel+:WIDTH] >>> (sel - MID);
            dout <= din >>> (sel - MID);
            //dout <= Idout[31:16];
        end
        else begin
            dout <= din[31:16];
        end
    end

    else begin
        dout <= {WIDTH{1'b0}}; 
    end

end

endmodule