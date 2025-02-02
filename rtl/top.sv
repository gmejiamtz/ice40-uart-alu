module top (
    input clk,
    input rst,
    input rx_i,
    output tx_o,
    output [7:0] ssd_o,
    output [4:0] led_o
);

logic [7:0] rx_data_out, fsm_out,rx_data_q,tx_data_q,slow_clock_out;
logic rx_valid_out,rx_to_fsm_ready_out,rx_to_fsm_valid_out;
logic tx_ready, fsm_valid_out,fsm_is_ready,fsm_to_tx_ready_o,fsm_to_tx_valid_o;
logic [6:0] half_byte1_seg,half_byte2_seg;

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
    .prescale(16'd35)
);

pipeline #(.width_p(8)) rx_to_fsm_inst(
    .clk_i(clk),
    .reset_i(rst),
    .data_i(rx_data_out),
    .valid_i(rx_valid_out),
    .ready_o(rx_to_fsm_ready_out),
    .valid_o(rx_to_fsm_valid_out),
    .data_o(rx_data_q),
    .ready_i(fsm_is_ready)
);

FSM #() fsm (
    .clk(clk),
    .rst(rst),
    .data_i(rx_data_q),
    .valid_i(rx_to_fsm_valid_out),
    .ready_o(fsm_is_ready),  //can fsm receive rn
    .data_o(fsm_out),
    .valid_o(fsm_valid_out),
    .ready_i(fsm_to_tx_ready_o), //can the tx transmit right now?
    .state_o(led_o)
);

pipeline #(.width_p(8)) fsm_to_tx_inst(
    .clk_i(clk),
    .reset_i(rst),
    .data_i(fsm_out),
    .valid_i(fsm_valid_out),
    .ready_o(fsm_to_tx_ready_o),
    .valid_o(fsm_to_tx_valid_o),
    .data_o(tx_data_q),
    .ready_i(tx_ready)
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(tx_data_q), // input
    .s_axis_tvalid(fsm_to_tx_valid_o), // input
    .s_axis_tready(tx_ready), // output
    .txd(tx_o),
    .busy(),
    .prescale(16'd35)
);


//debug hardware

hex2ssd #() hex1 (
    .hex_i(rx_data_q[3:0]),
    .ssd_o(half_byte1_seg)
);

hex2ssd #() hex2 (
    .hex_i(rx_data_q[7:4]),
    .ssd_o(half_byte2_seg)
);

bsg_counter_up_down #(
    .max_val_p(8'd255),
    .init_val_p(8'd255),
    .max_step_p(1)
)   slow_clock (
    .clk_i(clk),
    .reset_i(rst),
    .up_i(0),
    .down_i(1),
    .count_o(slow_clock_out)
);

assign ssd_o[7] = slow_clock_out[7];
assign ssd_o[6:0] = slow_clock_out[7] ? half_byte1_seg : half_byte2_seg;

endmodule
