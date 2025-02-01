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
    uart_runner.uart_device_send_data(8'hec);
    uart_runner.wait_cycle(100);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.wait_cycle(123);
    uart_runner.uart_device_send_data(8'h06);
    uart_runner.wait_cycle(421);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.wait_cycle(111);
    uart_runner.uart_device_send_data(8'h48);
    uart_runner.wait_cycle(89);
    uart_runner.uart_device_send_data(8'h69);
    uart_runner.wait_cycle(2000);
    uart_runner.wait_cycle(2000);
    uart_runner.wait_cycle(2000);
    uart_runner.uart_device_send_data(8'hec);
    uart_runner.wait_cycle(100);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.wait_cycle(123);
    uart_runner.uart_device_send_data(8'h06);
    uart_runner.wait_cycle(421);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.wait_cycle(111);
    uart_runner.uart_device_send_data(8'h48);
    uart_runner.wait_cycle(89);
    uart_runner.uart_device_send_data(8'h69);
    uart_runner.wait_cycle(2000);
    uart_runner.wait_cycle(2000);
    uart_runner.wait_cycle(2000);
    $display( "End simulation." );
    $finish;
end

endmodule
