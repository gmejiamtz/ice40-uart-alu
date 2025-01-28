
module icebreaker (
    input  wire CLK,
    input  wire BTN_N,
    input  wire BTN1,
    input wire [7:0] data_i,
    output wire LEDG_N
);

wire clk_12 = CLK;
wire clk_50;

// icepll -i 12 -o 50
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd66),
    .DIVQ(3'd4),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTCORE(clk_50)
);

top #() top_uut (
    .clk(clk_50),
    .rst(!BTN_N),
    .data_i(8'hac),
    .t_valid_i(BTN1),
    .tx_o(LEDG_N)
);

endmodule
