
module uart_runner;

localparam DATA_WIDTH_P = 8;

reg CLK;
reg BTN_N = 0;
reg BTN1 = 0;
logic RX,TX;

//uart_device signals
logic [DATA_WIDTH_P-1:0] uart_device_data_i, uart_device_data_o;
logic uart_device_tvalid_i,uart_device_tready_o,uart_device_rxd_i,
    uart_device_tvalid_o,uart_device_tready_i,
    uart_device_txd_o,uart_device_tx_busy_o,uart_device_rx_busy_o,
    uart_device_rx_overrun_error_o, uart_device_rx_frame_error_o;
logic [15:0] uart_device_prescale_i;

initial begin
    CLK = 0;
    forever begin
        #41.666ns; // 12MHz
        CLK = !CLK;
    end
end

localparam realtime ClockPeriod = 36.036ns;


logic pll_out;
initial begin
    pll_out = 0;
    forever begin
        #(ClockPeriod/2); // 32.256MHz
        pll_out = !pll_out;
    end
end
assign icebreaker.pll.PLLOUTGLOBAL = pll_out;

uart #() uart_device(
    .clk(pll_out),
    .rst(!BTN_N),
    .s_axis_tdata(uart_device_data_i),
    .s_axis_tvalid(uart_device_tvalid_i),
    .s_axis_tready(uart_device_tready_o),
    .m_axis_tdata(uart_device_data_o),
    .m_axis_tvalid(uart_device_tvalid_o),
    .m_axis_tready(uart_device_tready_i),
    .rxd(TX),
    .txd(uart_device_txd_o),
    .tx_busy(uart_device_tx_busy_o),
    .rx_busy(uart_device_rx_busy_o),
    .rx_overrun_error(uart_device_rx_overrun_error_o),
    .rx_frame_error(uart_device_rx_frame_error_o),
    .prescale(16'd35)
);

icebreaker icebreaker (
    .CLK(CLK),
    .BTN_N(BTN_N),
    .RX(uart_device_txd_o),
    .TX(TX)
);

task automatic reset;
    BTN_N <= 0;
    uart_device_data_i <= '0;
    uart_device_rxd_i <= '0;
    uart_device_tready_i <= '0;
    uart_device_tvalid_i <= '0;
    repeat (5) begin
        @(posedge CLK);
    end
    BTN_N <= 1;
    repeat (5) begin
        @(posedge CLK);
    end
endtask

task automatic uart_device_send_data(input [7:0] data_in);
    uart_device_data_i <= data_in;
    uart_device_tvalid_i <= 1;
    $info("Sending %h\n",data_in);
    @(posedge CLK);
    uart_device_tvalid_i <= 0;
    @(negedge uart_device_tx_busy_o);
endtask

task automatic wait_cycle(integer n);
    repeat (n) begin
        @(posedge CLK);
    end
endtask

task automatic wait_for_rx;
    @(negedge uart_device_rx_busy_o);
endtask

endmodule
