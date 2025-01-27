
module uart_runner;

localparam DATA_WIDTH_P = 8;

logic clk_i;
logic rst;
logic tx_i;
logic data_o;

//uart_device signals
logic [DATA_WIDTH_P-1:0] uart_device_data_i;
logic uart_device_tvalid_i,uart_device_tready_o,
    uart_device_txd_o,uart_device_busy_o,
    uart_device_prescale_i;

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
    .tx_o(data_o));

uart_tx #(.DATA_WIDTH(DATA_WIDTH_P)) uart_device(
    .clk(clk_i),
    .rst(rst),
    .s_axis_tdata(uart_device_data_i),
    .s_axis_tvalid(uart_device_tvalid_i),
    .s_axis_tready(uart_device_tready_o),
    .txd(uart_device_txd_o),
    .busy(uart_device_busy_o),
    .prescale(uart_device_prescale_i)
);

always @(posedge uart_device_busy_o) $info("Uart Transmitter busy");
always @(negedge uart_device_busy_o) $info("Uart Transmitter not busy!");

task automatic reset;
    rst <= 1;
    @(posedge clk_i);
    rst <= 0;
endtask

task automatic send_data (input [DATA_WIDTH_P-1:0] data_in);
    uart_device_data_i <= data_in;
    uart_device_tvalid_i <= 1'b1;
    while (uart_device_busy_o) @(posedge clk_i);
    uart_device_tvalid_i <= 1'b0;
endtask

endmodule
