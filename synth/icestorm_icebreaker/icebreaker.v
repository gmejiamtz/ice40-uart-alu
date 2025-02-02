
module icebreaker (
    input wire CLK,
    input wire BTN_N,
    input wire RX,
    output wire TX,
    output wire [7:0] ssd_o,
    output wire [4:0] led_o
);

wire clk_12 = CLK;
wire clk_27_750;

// icepll -i 12 -o 32.256
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
    .PLLOUTGLOBAL(clk_27_750)
);


top top_inst (.clk(clk_27_750), .rst(!BTN_N), .rx_i(RX), .tx_o(TX),.ssd_o(ssd_o),.led_o(led_o));

endmodule
