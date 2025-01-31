module FSM import config_pkg::*; (
    input clk,
    input rst,
    input [7:0] data_i,
    input valid_i,
    output data_o
);

logic [7:0] opcode_reg_q, opcode_reg_d, reserverd_reg_q, reserverd_reg_d, lsb_reg_q, lsb_reg_d,
            msb_reg_q, msb_reg_d, rs1_reg_q, rs1_reg_d, rs2_reg_q, rs2_reg_d;
logic up_i;
logic [15:0] count_o;
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

);

always_comb begin
    up_i = 0;

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
            up_i = 1;
            state_d = LSB;
        end
        LSB: begin
            if(count_o == 3 && valid_i) begin
                lsb_reg_d = data_i;
                up_i = 1;
                state_d = MSB;
            end
        end
        MSB: begin
            if(count_o == 4 && valid_i) begin // error check for if length is less than 4
                msb_reg_d = data_i;
                up_i = 1;
                if(opcode_reg_q == ECHO) begin
                    state_d = COMPUTE;
                end else begin
                    state_d = RS1;
                end
            end
        end
        RS1: begin
            if(count_o != )
        end
        COMPUTE: begin

        end

    default: state_d = OPCODE;
    endcase
end

endmodule
