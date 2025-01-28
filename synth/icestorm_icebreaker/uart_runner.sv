
module uart_runner;

reg CLK;
reg BTN_N = 0;
reg BTN1 = 0;
wire LEDG_N;
logic [7:0] data_i;

initial begin
    CLK = 0;
    forever begin
        #41.666ns; // 12MHz
        CLK = !CLK;
    end
end

logic pll_out;
initial begin
    pll_out = 0;
    forever begin
        #25.000ns; // 50MHz
        pll_out = !pll_out;
    end
end
assign icebreaker.pll.PLLOUTGLOBAL = pll_out;

icebreaker icebreaker (
    .CLK(CLK),
    .BTN_N(BTN_N),
    .BTN1(BTN1),
    .data_i(data_i),
    .LEDG_N(LEDG_N)
);

task automatic reset;
    BTN_N <= 0;
    BTN1 <= 0;
    @(posedge CLK);
    BTN_N <= 1;
    BTN1 <= 0;
endtask

task automatic send_data(input [7:0] data_in);
    data_i <= data_in;
    BTN1 <= 1;
    $info("Sending %h\n",data_in);
    @(posedge CLK);
endtask

task automatic wait_cycle(integer n);
    repeat (n) begin
        @(posedge CLK);
    end
endtask

endmodule
