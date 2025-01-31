module FSM import config_pkg::*; (
    input clk,
    input rst,
    input [7:0] data_i,
    input valid_i,
    output [7:0] data_o,
    output valid_o,
    input ready_i
);

logic [7:0] opcode_reg_q, opcode_reg_d, reserverd_reg_q, reserverd_reg_d, lsb_reg_q, lsb_reg_d,
            msb_reg_q, msb_reg_d;
logic packet_up_i, rs1_up_i;
logic [15:0] count_o,data_length;
logic [31:0] rs1_reg_q, rs1_reg_d, rs2_reg_q, rs2_reg_d,rs1,rs2;
logic [63:0] tx_reg_q,tx_req_d;
state_t state_q, state_d;
always_ff @(posedge clk) begin
    if(rst) begin
        state_q <= OPCODE;
    end else begin
        state_q <= state_d;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        opcode_reg_q <= 0;
        reserverd_reg_q <= 0;
        lsb_reg_q <= 0;
        msb_reg_q <= 0;
        rs1_reg_q <= 0;
        rs2_reg_q <= 0;
    end else begin
        opcode_reg_q <= opcode_reg_d;
        reserverd_reg_q <= reserverd_reg_d;
        lsb_reg_q <= lsb_reg_d;
        msb_reg_q <= msb_reg_d;
    end
end

bsg_counter_up_down #(.max_val_p(16'd65535),
                      .init_val_p(0),
                      .max_step_p(1))
packet_counter(
    .clk_i(clk),
    .reset_i(rst),
    .up_i(packet_up_i),
    .down_i(0),
    .count_o(packet_count_o)
);

bsg_counter_up_down #(.max_val_p(16'd65535),
                      .init_val_p(0),
                      .max_step_p(1))
rs1_counter(
    .clk_i(clk),
    .reset_i(rst),
    .up_i(rs1_up_i),
    .down_i(0),
    .count_o(rs1_count_o)
);

logic rs1_en_i;
assign rs1_en_i = state_q == RS1 && valid_i;
shift_8 #() rs1_shift(
    .clk_i(clk),
    .rst(rst),
    .en_i(rs1_en_i),
    .data_i(data_i),
    .data_o(rs1_reg_q)
);

logic rs2_en_i;
assign rs2_en_i = state_q == RS2 && valid_i;
shift_8 #() rs2_shift(
    .clk_i(clk),
    .rst(rst),
    .en_i(rs2_en_i),
    .data_i(data_i),
    .data_o(rs2_reg_q)
);

alu #() alu_inst(
    .clk(clk),
    .rst(rst),
    .opcode_i(opcode_reg_q),
    .data1_i(rs1_reg_q),
    .data2_i(rs2_reg_q),
    .data_o(tx_req_d)
);

always_comb begin
    packet_up_i = 0;
    rs1_up_i = 0;
    data_length = {msb_reg_q,lsb_reg_q} - 4; //4 frames are for metadata
    unique case(state_q)
        OPCODE: begin
            if(packet_count_o == 0 && valid_i) begin
                if((data_i == ECHO) || (data_i == ADD) || (data_i == MUL) || (data_i == DIV)) begin
                    opcode_reg_d = data_i;
                    packet_up_i = 1;
                    state_d = RESERVED;
                end
            end
        end
        RESERVED: begin
            if(valid_i) begin
                packet_up_i = 1;
                state_d = LSB;
            end
        end
        LSB: begin
            if(valid_i) begin
                lsb_reg_d = data_i;
                packet_up_i = 1;
                state_d = MSB;
            end
        end
        MSB: begin
            if(valid_i) begin // error check for if length is less than 4
                msb_reg_d = data_i;
                packet_up_i = 1;
                //if no data just go back to expect a new opcode
                if(data_length == 0) begin
                    state_d = OPCODE;
                end else if(opcode_reg_q == ECHO) begin
                    state_d = COMPUTE;
                end else begin
                    state_d = RS1;
                end
            end
        end
        RS1: begin
            if((data_length != (packet_count_o - 4)) && (rs1_count_o != 4)) begin
                rs1_up_i = 1;
            end else if (data_length != (packet_count_o - 4)) begin
                state_d = RS2;
            end else begin
                state_d = COMPUTE;
            end
        end
        RS2: begin
            if((data_length != (packet_count_o - 4)) && (rs2_count_o != 4)) begin
                rs2_up_i = 1;
            end else begin
                state_d = COMPUTE;
            end
        end
        COMPUTE: begin

        end

    default: state_d = OPCODE;
    endcase
end

endmodule
