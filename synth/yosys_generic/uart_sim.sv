
module uart_sim (
    input clk,
    input rst,
    input [7:0] data_i,
    input t_valid_i,
    output tx_o,
    output [7:0] data_o
);

top #() top_uut (.*);

endmodule
