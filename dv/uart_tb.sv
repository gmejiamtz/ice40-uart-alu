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
    $display("Echo - Hi010203040506");
    //send echo Hi123456 - 0xec_xx_0c_00_48_69_01_02_03_04_05_06
    uart_runner.uart_device_send_data(8'hD1); //op
    uart_runner.uart_device_send_data(8'h00); //res
    uart_runner.uart_device_send_data(8'h0c); //lsb
    uart_runner.uart_device_send_data(8'h00); //msb - 8 data
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h0c);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h00);
    uart_runner.uart_device_send_data(8'h02);
    uart_runner.wait_cycle(20000);
    $display("Echo - 1 2");
    //send add 1 2 - 0xad_xx_0c_00_00_00_00_01_00_00_00_02
    uart_runner.uart_device_send_data(8'hec); //op
    uart_runner.uart_device_send_data(8'h00); //res
    uart_runner.uart_device_send_data(8'h0c); //lsb
    uart_runner.uart_device_send_data(8'h00); //msb - 8 data
    uart_runner.uart_device_send_data(8'hDE);
    uart_runner.uart_device_send_data(8'hAD);
    uart_runner.uart_device_send_data(8'hBE);
    uart_runner.uart_device_send_data(8'hEF);
    uart_runner.uart_device_send_data(8'h1A);
    uart_runner.uart_device_send_data(8'h98);
    uart_runner.uart_device_send_data(8'h31);
    uart_runner.uart_device_send_data(8'hab);
    uart_runner.wait_cycle(10000);
    // uart_runner.uart_device_send_data(8'hac); //op
    // uart_runner.uart_device_send_data(8'h00); //res
    // uart_runner.uart_device_send_data(8'h0c); //lsb
    // uart_runner.uart_device_send_data(8'h00); //msb - 8 data
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h03);
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h00);
    // uart_runner.uart_device_send_data(8'h02);
    // uart_runner.wait_cycle(10000);
    $display( "End simulation." );
    $finish;
end

endmodule
