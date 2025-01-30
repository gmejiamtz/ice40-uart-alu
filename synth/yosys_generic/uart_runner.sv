
module uart_runner;

localparam DATA_WIDTH_P = 8;

logic clk_i;
logic rst;
logic top_tx_o;

//uart_device signals
logic [DATA_WIDTH_P-1:0] uart_device_data_i, uart_device_data_o;
logic uart_device_tvalid_i,uart_device_tready_o,uart_device_rxd_i,
    uart_device_tvalid_o,uart_device_tready_i,
    uart_device_txd_o,uart_device_tx_busy_o,uart_device_rx_busy_o,
    uart_device_rx_overrun_error_o, uart_device_rx_frame_error_o;
logic [15:0] uart_device_prescale_i;


localparam realtime ClockPeriod = 5ms;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

top #() top_uut (.clk(clk_i),
    .rst(rst),
    .rx_i(uart_device_txd_o),
    .tx_o(top_tx_o)
);

uart #() uart_device(
    .clk(clk_i),
    .rst(rst),
    .s_axis_tdata(uart_device_data_i),
    .s_axis_tvalid(uart_device_tvalid_i),
    .s_axis_tready(uart_device_tready_o),
    .m_axis_tdata(uart_device_data_o),
    .m_axis_tvalid(uart_device_tvalid_o),
    .m_axis_tready(uart_device_tready_i),
    .rxd(top_tx_o),
    .txd(uart_device_txd_o),
    .tx_busy(uart_device_tx_busy_o),
    .rx_busy(uart_device_rx_busy_o),
    .rx_overrun_error(uart_device_rx_overrun_error_o),
    .rx_frame_error(uart_device_rx_frame_error_o),
    .prescale(uart_device_prescale_i)
);

task automatic reset;
    rst <= 1;
    uart_device_prescale_i <= 16'h1;
    uart_device_data_i <= '0;
    uart_device_rxd_i <= '0;
    uart_device_tready_i <= '0;
    uart_device_tvalid_i <= '0;
    repeat (5) begin
        @(posedge clk_i);
    end
    rst <= 0;
    repeat (5) begin
        @(posedge clk_i);
    end
endtask

task automatic uart_device_send_data (input [DATA_WIDTH_P-1:0] data_in);
    uart_device_data_i <= data_in;
    uart_device_tvalid_i <= 1'b1;
    $info("Sending %h\n",data_in);
    @(posedge clk_i);
    uart_device_tvalid_i <= 1'b0;
    @(posedge uart_device_tready_o);
endtask

task automatic wait_cycle(integer n);
    repeat (n) begin
        @(posedge clk_i);
    end
endtask

endmodule
