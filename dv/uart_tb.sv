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
    uart_runner.uart_device_send_data(8'hec); //op
    uart_runner.uart_device_send_data(8'hf4); //res
    uart_runner.uart_device_send_data(8'h0c); //lsb
    uart_runner.uart_device_send_data(8'h00); //msb - 8 data
    uart_runner.uart_device_send_data(8'h48);
    uart_runner.uart_device_send_data(8'h69);
    uart_runner.uart_device_send_data(8'h01);
    uart_runner.uart_device_send_data(8'h02);
    uart_runner.uart_device_send_data(8'h03);
    uart_runner.uart_device_send_data(8'h04);
    uart_runner.uart_device_send_data(8'h05);
    uart_runner.uart_device_send_data(8'h06);
    uart_runner.wait_cycle(2000);
    uart_runner.wait_cycle(2000);
    $display( "End simulation." );
    $finish;
end

endmodule
