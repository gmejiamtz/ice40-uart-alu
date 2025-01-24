
module blinky_runner;

localparam DATA_WIDTH_P = 0

logic clk_i;
logic rst;
logic tx_i;
logic data_o;

//uart_device signals
logic [DATA_WIDTH_P-1:0] uart_device_data_i
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

top #() top_uut (.clk_i(clk_i),
    .rst(rst),
    .tx_i(uart_device_txd_o)),
    .data_o(data_o);

uart_tx #(DATA_WIDTH=DATA_WIDTH_P) uart_device(
    .clk(clk),
    .rst(rst_ni),
    .s_axis_tdata(uart_device_data_i),
    .s_axis_tvalid(uart_device_tvalid_i),
    .s_axis_tready(uart_device_tready_o),
    .txd(uart_device_txd_o),
    .busy(uart_device_busy_o),
    .prescale(uart_device_prescale_i)
);

always @(posedge led_o) $info("Led on");
always @(negedge led_o) $info("Led off");

task automatic reset;
    rst_ni <= 1;
    @(posedge clk_i);
    rst_ni <= 0;
endtask

task automatic wait_for_on;
    while (!led_o) @(posedge led_o);
endtask

task automatic wait_for_off;
    while (led_o) @(negedge led_o);
endtask

endmodule
