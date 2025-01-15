module top (
    input clk,
    input rst,
    input rx_i,
    output tx_o
);

wire [7:0] data_o;

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(data_o),
    .m_axis_tvalid(),
    .m_axis_tready(),
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale()
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(data_o),
    .s_axis_tvalid(),
    .s_axis_tready(),
    .txd(tx_o),
    .busy(),
    .prescale()
);

endmodule
