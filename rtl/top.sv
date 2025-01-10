module top (
    input clk,
    input rst,
    input tx_i,
    output data_o
);

wire txd_o;

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(data_o),
    .m_axis_tvalid(),
    .m_axis_tready(),
    .rxd(txd_o),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale()
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(tx_i),
    .s_axis_tvalid(),
    .s_axis_tready(),
    .txd(txd_o),
    .busy(),
    .prescale()
);

endmodule
