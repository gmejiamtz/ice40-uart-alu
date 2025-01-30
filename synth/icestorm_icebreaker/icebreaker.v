
module icebreaker (
    input wire CLK,
    input wire BTN_N,
    input wire RX,
    output wire TX
);

wire clk_12 = CLK;
wire clk_32_256;

// icepll -i 12 -o 25
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd85),
    .DIVQ(3'd5),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTGLOBAL(clk_32_256)
);


top top_inst (.clk(clk_32_256), .rst(BTN_N), .rx_i(RX), .tx_o(TX));

endmodule
