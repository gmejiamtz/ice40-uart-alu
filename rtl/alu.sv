module alu import config_pkg::*; (
    input clk,
    input rst,
    input [7:0] opcode_i,
    input [1:0] top_byte_i,
    input [32:0] data1_i,
    input data1_valid_i,
    input [32:0] data2_i,
    input data2_valid_i,
    input start_alu_i,
    output logic [63:0] data_o,
    output busy_o,
    output logic valid_o
);

logic [32:0] add_init_const, mult_init_const,data1_reg_d,data1_reg_q,data2_reg_d,data2_reg_q;
logic [5:0] shift_amount;
logic [2:0] add_echo_packet_count,packets_to_process;
logic add_echo_packet_up,busy_q,busy_d;
logic [7:0] byte_selected;

always_ff @(posedge clk) begin
    if(rst) begin
        busy_q <= '0;
    end else begin
        busy_q <= busy_d;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        data1_reg_q <= '0;
        data2_reg_q <= '0;
    end else begin
        data1_reg_q <= data1_reg_d;
        data2_reg_q <= data2_reg_d;
    end
end

bsg_counter_up_down #(
    .max_val_p(3'd4),
    .init_val_p(0),
    .max_step_p(1)
    )
    echo_add_shift_counter(
        .clk_i(clk),
        .reset_i(rst | start_alu_i),
        .up_i(add_echo_packet_up),
        .down_i(0),
        .count_o(add_echo_packet_count)
    );

select_byte select_byte_inst(
    .data_i(data1_reg_q),
    .byte_index_i(top_byte_i),
    .byte_o(byte_selected),
    .shift_amount_o(shift_amount)
);

//note: probably need to switch add,mult,div to use basejump stl modules

//note: need to fix alu. ethan told sean that alu can only have clk,rst, rx_i, and tx_o as i/o ports.
//meaning we cant have a state_start_i and instead need to do the alu in the state machine


always_comb begin
    add_init_const = 32'b0;
    mult_init_const = 32'b1;
    busy_d = '0;
    data1_reg_d = '0;
    data2_reg_d = '0;
    valid_o = '0;
    packets_to_process = ~|top_byte_i ? 3'd4 : top_byte_i;
    data_o = '0;
    if(data1_valid_i & start_alu_i & ~busy_o) begin
        data1_reg_d = data1_i;
        busy_d = 1;
    end
    if(data2_valid_i & start_alu_i & ~busy_o) begin
        data2_reg_d = data2_i;
        busy_d = 1;
    end

    case(opcode_i)
        //echo
        8'hEC: begin
            if(busy_o) begin
                valid_o = '1;
                if(add_echo_packet_count != packets_to_process) begin
                    busy_d = '1;
                    data_o = byte_selected;
                    data1_reg_d = data2_reg_q << 8;
                end else begin
                    busy_d = '0;
                end
            end
        end
        //addition
        8'hAD: data_o = '0;

        //multiply
        8'hAC: data_o = '0;

        //division, we need to change this
        //sean was thinking we do a system where we take the first rx_i then divide by 1,
        //and then on the next loop of the compute stage we do intermediate variable divided by the next rx_i
        8'hD1: data_o = data1_i / data2_i;

        default : data_o = data1_i;
    endcase
end

assign busy_o = busy_q;

endmodule
