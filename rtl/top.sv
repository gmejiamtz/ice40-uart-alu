module top (
    input clk,
    input rst,
    input rx_i,
    output tx_o
);

logic [7:0] rx_o;

//logic t_ready_o,r_valid_o;

//wire [7:0] actual_data_in;

//assign actual_data_in = data_i & {8{t_valid_i}} | data_o & {8{r_valid_o}};

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(rx_o),
    .m_axis_tvalid(),
    .m_axis_tready(),
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(1)
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(rx_o),
    .s_axis_tvalid(),
    .s_axis_tready(),
    .txd(tx_o),
    .busy(),
    .prescale(1)
);


// uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
//     .clk(clk),
//     .rst(rst),
//     .m_axis_tdata(data_o),
//     .m_axis_tvalid(r_valid_o),
//     .m_axis_tready(t_ready_o),
//     .rxd(tx_o),
//     .busy(),
//     .overrun_error(),
//     .frame_error(),
//     .prescale(1)
// );

// uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
//     .clk(clk),
//     .rst(rst),
//     .s_axis_tdata(actual_data_in),
//     .s_axis_tvalid(t_valid_i | r_valid_o),
//     .s_axis_tready(t_ready_o),
//     .txd(tx_o),
//     .busy(),
//     .prescale(1)
// );


endmodule
