
dv/dv_pkg.sv
dv/uart_runner.sv
dv/uart_tb.sv

--timing
-j 0
-Wall
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

-Werror-IMPLICIT
-Werror-USERERROR
-Werror-LATCH
-Wno-WIDTHTRUNC
-Wno-WIDTHEXPAND
-Wno-UNUSEDSIGNAL
-Wno-UNDRIVEN
