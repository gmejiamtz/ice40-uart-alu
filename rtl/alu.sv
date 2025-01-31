module alu import config_pkg::*; (
    input clk,
    input rst,
    input [7:0] opcode_i,
    input [1:0] top_byte,
    input [32:0] data1_i,
    input [32:0] data2_i,
    output [63:0] data_o;
);

logic [32:0] add_init_const, mult_init_const;
logic [5:0] shift_amount;

select_byte select_byte_inst(
    .data_i(data1_i),
    .byte_index_i(packet_counter[1:0]),
    .shift_amount_o(shift_amount)
);

//note: probably need to switch add,mult,div to use basejump stl modules

always_comb begin
add_init_const = 32'b0;
mult_init_const = 32'b1;

case(opcode_i)
    //echo
    8'hEC: begin
        data_o =

    end
    //addition
    8'hAD: data_o = add_init_const + data1_i;

    //multiply
    8'hAC: data_o = mult_init_const * data1_i;

    //division
    8'hD1: data_o = data1_i / data2_i;

    default : data_o = data_i;
endcase



end


endmodule
