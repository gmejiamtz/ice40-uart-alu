
module uart_sim (
    input clk,
    input rst,
    input rx_i,
    output tx_o,
    output [4:0] led_o,
    output [7:0] ssd_o
);

top #() top_uut (.*);

endmodule
