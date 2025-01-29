module uart_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

uart_runner uart_runner ();
always begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);
    uart_runner.reset();
    uart_runner.uart_device_send_data(8'hac);
    uart_runner.wait_cycle(256);
    $display( "End simulation." );
    $finish;
end

endmodule
