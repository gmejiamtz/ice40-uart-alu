
module icebreaker (
    input wire CLK,
    output wire RX,
    input wire BTN_N,
    `ifndef SYNTHESIS
    input [7:0] data_i
    `endif
    input wire BTN1,
    output wire LEDG_N
    input wire TX
);

wire clk_12 = CLK;
wire clk_25;

// icepll -i 12 -o 25
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd66),
    .DIVQ(3'd5),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTCORE(clk_25)
);

top uart_top (.clk(clk_o), .rst(BTN_N), .data_i(TX), .t_valid_i(t_valid_i), .tx_o(RX), .data_o(data_o));

top #() top_uut (
    .clk(clk_25),
    .rst(!BTN_N),
    .data_i(8'hac),
    .t_valid_i(BTN1),
    .tx_o(LEDG_N)
);

endmodule
