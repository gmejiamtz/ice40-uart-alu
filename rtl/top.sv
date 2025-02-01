module top (
    input clk,
    input rst,
    input rx_i,
    output tx_o
);

logic [7:0] rx_data_out, fsm_out;
logic rx_valid_out;
logic tx_ready, fsm_valid_out,fsm_is_ready;

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(rx_data_out), // output
    .m_axis_tvalid(rx_valid_out), // output
    .m_axis_tready(fsm_is_ready), // input
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(16'd31)
);

FSM #() fsm (
    .clk(clk),
    .rst(rst),
    .data_i(rx_data_out),
    .valid_i(rx_valid_out),
    .ready_o(fsm_is_ready),  //can fsm receive rn
    .data_o(fsm_out),
    .valid_o(fsm_valid_out),
    .ready_i(tx_ready) //can the tx transmit right now?
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(fsm_out), // input
    .s_axis_tvalid(fsm_valid_out), // input
    .s_axis_tready(tx_ready), // output
    .txd(tx_o),
    .busy(),
    .prescale(16'd31)
);

endmodule
