module FSM import config_pkg::*; (
    input clk,
    input rst,
    input [7:0] data_i, //from upstream
    input valid_i,      //from upstream
    output logic ready_o,   //to upstream
    output logic [7:0] data_o,  //to down
    output logic valid_o,   //to down
    input ready_i,       //from down
    output logic [4:0] state_o //debug
);

logic [7:0] packet_count_o,opcode_reg_q, opcode_reg_d, reserverd_reg_q, reserverd_reg_d, lsb_reg_q, lsb_reg_d,
            msb_reg_q, msb_reg_d;
logic packet_up, rs1_up,rs2_up,rs1_valid_d,rs1_valid_q,
    rs2_valid_d,rs2_valid_q,start_alu,alu_busy,alu_valid,packet_count_rst,
    rs1_reset,rs2_reset;
logic [15:0] rs1_count_o,rs2_count_o,data_length;
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
        rs1_valid_q <= '0;
        rs2_valid_q <= '0;
    end else begin
        rs1_valid_q <= rs1_valid_d;
        rs2_valid_q <= rs2_valid_d;
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

bsg_counter_up_down #(.max_val_p(8'd255),
                      .init_val_p(0),
                      .max_step_p(1))
packet_counter(
    .clk_i(clk),
    .reset_i(rst | packet_count_rst),
    .up_i(packet_up),
    .down_i(0),
    .count_o(packet_count_o)
);

bsg_counter_up_down #(.max_val_p(16'd65535),
                      .init_val_p(0),
                      .max_step_p(1))
rs1_counter(
    .clk_i(clk),
    .reset_i(rst | rs1_reset),
    .up_i(rs1_up),
    .down_i(0),
    .count_o(rs1_count_o)
);

bsg_counter_up_down #(.max_val_p(16'd65535),
                      .init_val_p(0),
                      .max_step_p(1))
rs2_counter(
    .clk_i(clk),
    .reset_i(rst | rs2_reset),
    .up_i(rs2_up),
    .down_i(0),
    .count_o(rs2_count_o)
);

logic rs1_en_i;
shift_8 #() rs1_shift(
    .clk_i(clk),
    .rst(rst),
    .en_i(rs1_en_i),
    .data_i(data_i),
    .data_o(rs1_reg_q)
);

logic rs2_en_i;
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
    .top_byte_i(packet_count_o[1:0]),
    .data1_i(rs1_reg_q),
    .data1_valid_i(rs1_valid_q),
    .data2_i(rs2_reg_q),
    .data2_valid_i(rs2_valid_q),
    .start_alu_i(start_alu),
    .data_o(tx_req_d),
    .busy_o(alu_busy),
    .valid_o(alu_valid)
);

always_comb begin
    state_d = state_q;
    packet_count_rst = '0;
    packet_up = 0;
    rs1_up = 0;
    rs2_up = 0;
    rs1_reset = 0;
    rs2_reset = 0;
    rs1_valid_d = 0;
    rs2_valid_d = 0;
    rs1_en_i = '0;
    rs2_en_i = '0;
    msb_reg_d = msb_reg_q;
    lsb_reg_d = lsb_reg_q;
    opcode_reg_d = opcode_reg_q;
    reserverd_reg_d = reserverd_reg_q;
    rs1_reg_d = rs1_reg_q;
    rs2_reg_d = rs2_reg_q;
    valid_o = '0;
    ready_o = '0;
    data_o = '0;
    state_o = '0;
    data_length = {msb_reg_q,lsb_reg_q}; //4 frames are for metadata
    unique case(state_q)
        OPCODE: begin
            ready_o = '1;
            state_o = 5'b00001;
            if( ~|packet_count_o && valid_i && ready_o) begin
                if((data_i == ECHO) || (data_i == ADD) || (data_i == MUL) || (data_i == DIV)) begin
                    packet_up = 1;
                    ready_o = '0;
                    state_d = OPCODE;
                    opcode_reg_d = data_i;
                end
            end
            if(packet_count_o == 1 && valid_i && ready_o) begin
                state_d = RESERVED;
                ready_o = '1;
            end
        end
        RESERVED: begin
            ready_o = '1;
            state_o = 5'b00010;
            if(valid_i && ready_o && (packet_count_o == 1)) begin
                ready_o = '0;
                packet_up = 1;
                state_d = RESERVED;
                reserverd_reg_d = data_i;
            end

            if(packet_count_o == 2 && valid_i && ready_o) begin
                state_d = LSB;
                ready_o = '1;
            end
        end
        LSB: begin
            state_o = 5'b00011;
            ready_o = '1;
            if(valid_i && ready_o && (packet_count_o == 2)) begin
                ready_o = '0;
                packet_up = 1;
                state_d = LSB;
                lsb_reg_d = data_i;
            end

            if(packet_count_o == 3 && valid_i && ready_o) begin
                state_d = MSB;
                ready_o = '1;
            end
        end
        MSB: begin
            state_o = 5'b00100;
            ready_o = '1;
            if(valid_i && ready_o&& (packet_count_o == 3)) begin // error check for if length is less than 4
                ready_o = '0;
                packet_up = 1;
                state_d = MSB;
                msb_reg_d = data_i;
            end
            if(packet_count_o == 4 && valid_i && ready_o) begin
                ready_o = '1;
                //if no data just go back to expect a new opcode
                if(data_length == 0) begin
                    state_d = OPCODE;
                end else if(opcode_reg_q == ECHO) begin
                    state_d = COMPUTE;
                end else begin
                    state_d = RS1;
                    rs1_reset = 1;
                end
            end
        end
        RS1: begin
            ready_o = '1;
            rs1_reset = 0;
            state_o = 5'b00101;
            if(valid_i && ready_o) begin
                if((data_length != (packet_count_o)) && (rs1_count_o != 4)) begin
                    rs1_up = 1;
                    rs1_en_i = '1;
                    packet_up = 1;
                    state_d = RS1;
                end else if (data_length != (packet_count_o - 4)) begin
                    rs1_valid_d = '1;
                    state_d = RS2;
                    ready_o = '0;
                    packet_up = 1;
                    rs2_reset = 1;
                end else begin
                    rs1_valid_d = '1;
                    state_d = COMPUTE;
                end
            end
        end
        RS2: begin
            state_o = 5'b00110;
            ready_o = '1;
            rs2_reset = 0;
            if(valid_i && ready_o) begin
                if((data_length != (packet_count_o)) && (rs2_count_o != 4)) begin
                    rs2_up = 1;
                    rs2_en_i = '1;
                    packet_up = 1;
                end else begin
                    rs2_valid_d = '1;
                    ready_o = '0;
                    state_d = COMPUTE;
                end
            end
        end
        COMPUTE: begin
            ready_o = '1;
            state_o = 5'b00111;
            packet_up = '0;
            if(valid_i && ready_o && (packet_count_o != data_length)) begin
                if(opcode_reg_q == ECHO && ready_i) begin
                    packet_up = 1;
                    valid_o = '1;
                    data_o = data_i;
                    state_d = COMPUTE;
                end
            end else if ((packet_count_o == data_length)) begin
                ready_o = '1;
                state_d = OPCODE;
                lsb_reg_d = '0;
                msb_reg_d = '0;
                rs1_reg_d = '0;
                rs2_reg_d = '0;
                opcode_reg_d = '0;
                reserverd_reg_d = '0;
                packet_count_rst = '1;
                data_o = '0;
                valid_o = '0;
            end
        end
    default: state_d = OPCODE;
    endcase
end

endmodule
