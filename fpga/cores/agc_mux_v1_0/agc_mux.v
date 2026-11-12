
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

localparam integer MID = (N_POSITIONS / 2) - 1;

// Interpret the 32-bit input as a signed number
wire signed [31:0] signed_in = $signed(din);

reg signed [31:0] shifted;

always @(*) begin
    if (sel < MID) begin
        // Amplify by 2^(MID - sel)
        shifted = signed_in <<< (MID - sel);
    end
    else if (sel > MID) begin
        // Attenuate by 2^(sel - MID)
        shifted = signed_in >>> (sel - MID);
    end
    else begin
        // Unity gain
        shifted = signed_in;
    end
    
end

always @(posedge clk) begin
    if (clken) begin
        // Always extract the same 16-bit portion
        dout <= shifted[31:16];
    end
    else begin
        dout <= {WIDTH{1'b0}};
    end
end

endmodule