
module blinky_runner;

logic clk_i;
logic rst_ni;
logic led_o;

localparam realtime ClockPeriod = 5ms;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

top #() top_uut (.*);

uart #() uart_device(
    .clk(clk),
    .rst(!rst_ni),
    .
);

always @(posedge led_o) $info("Led on");
always @(negedge led_o) $info("Led off");

task automatic reset;
    rst_ni <= 0;
    @(posedge clk_i);
    rst_ni <= 1;
endtask

task automatic wait_for_on;
    while (!led_o) @(posedge led_o);
endtask

task automatic wait_for_off;
    while (led_o) @(negedge led_o);
endtask

endmodule