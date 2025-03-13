
-I${BASEJUMP_STL_DIR}/bsg_misc
${BASEJUMP_STL_DIR}/bsg_misc/bsg_counter_up_down.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_imul_iterative.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_idiv_iterative.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_mux_one_hot.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_idiv_iterative_controller.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_adder_cin.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_dff_en.sv
${BASEJUMP_STL_DIR}/bsg_misc/bsg_counter_clear_up.sv

-I${ALEXFORENCICH_UART_DIR}/rtl
${ALEXFORENCICH_UART_DIR}/rtl/uart_rx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart_tx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart.v

rtl/config_pkg.sv

rtl/top.sv
rtl/alu.sv
rtl/FSM.sv
rtl/select_byte.sv
rtl/shift_8.sv
rtl/hex2ssd.sv
rtl/pipeline.sv
