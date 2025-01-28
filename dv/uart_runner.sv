
module uart_runner;

localparam DATA_WIDTH_P = 8;

logic clk_i;
logic rst;
logic tx_i,tx_o;
logic [DATA_WIDTH_P-1:0] data_i,data_o;
logic t_valid_i;

//uart_device signals
/*
logic [DATA_WIDTH_P-1:0] uart_device_data_i;
logic uart_device_tvalid_i,uart_device_tready_o,
    uart_device_txd_o,uart_device_busy_o,
    uart_device_prescale_i;
*/
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
    .data_i(data_i),
    .t_valid_i(t_valid_i),
    .tx_o(tx_o),
    .data_o(data_o)
);

/*

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

*/

task automatic reset;
    rst <= 1;
    data_i <= '0;
    t_valid_i <= '0;
    repeat (5) begin
        @(posedge clk_i);
    end
    rst <= 0;
    repeat (5) begin
        @(posedge clk_i);
    end
endtask

task automatic send_data (input [DATA_WIDTH_P-1:0] data_in);
    data_i <= data_in;
    t_valid_i <= 1'b1;
    $info("Sending %h\n",data_in);
    @(posedge clk_i);
endtask

task automatic wait_cycle(integer n);
    repeat (n) begin
        @(posedge clk_i);
    end
endtask

endmodule
