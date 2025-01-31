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
logic up_i;
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
        rs1_reg_q <= rs1_reg_d;
        rs2_reg_q <= rs2_reg_d;
    end
end

bsg_counter_up_down #(.max_val_p(16'd65535),
                      .init_val_p(0),
                      .max_step_p(1))
packet_counter(
    .clk_i(clk),
    .reset_i(rst),
    .up_i(up_i),
    .down_i(0),
    .count_o(count_o)
);

alu #() alu_inst(
    .clk(clk),
    .rst(rst),
    .opcode_i(opcode_reg_q),
    .data1_i(rs1),
    .data2_i(rs2),
    .data_o(tx_req_d)
);

always_comb begin
    up_i = 0;
    data_length = {msb_reg_q,lsb_reg_q} >> 2; //4 frames are for metadata
    unique case(state_q)
        OPCODE: begin
            if(count_o == 0 && valid_i) begin
                if((data_i == ECHO) || (data_i == ADD) || (data_i == MUL) || (data_i == DIV)) begin
                    opcode_reg_d = data_i;
                    up_i = 1;
                    state_d = RESERVED;
                end
            end
        end
        RESERVED: begin
            if(valid_i) begin
                up_i = 1;
                state_d = LSB;
            end
        end
        LSB: begin
            if(valid_i) begin
                lsb_reg_d = data_i;
                up_i = 1;
                state_d = MSB;
            end
        end
        MSB: begin
            if(valid_i) begin // error check for if length is less than 4
                msb_reg_d = data_i;
                up_i = 1;
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
            if(count_o != )
            rs2
        end
        COMPUTE: begin
            if(opcode == ECHO) begin
                //10_00_00_23
                rs1 = {24'b0,data_i};
                rs2 = '0;
            end else begin
                rs1 = rs1_reg_q;
                rs2 = rs2_reg_q;
            end
            //if compute done and still stuff to process go to rs1
            //else go to opcode
        end

    default: state_d = OPCODE;
    endcase
end

endmodule
