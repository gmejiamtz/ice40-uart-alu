
rtl/config_pkg.sv

-DNO_ICE40_DEFAULT_ASSIGNMENTS
${YOSYS_DATDIR}/ice40/cells_sim.v

-I${ALEXFORENCICH_UART_DIR}/rtl
${ALEXFORENCICH_UART_DIR}/rtl/uart_rx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart_tx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart.v

synth/icestorm_icebreaker/build/synth.v
synth/icestorm_icebreaker/uart_runner.sv
