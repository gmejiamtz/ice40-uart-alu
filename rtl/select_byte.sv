module select_byte(
    input [31:0] data_i,
    input [1:0] byte_index_i,
    output [7:0] byte_o,
    output [5:0] shift_amount_o;
);

logic [7:0] byte_l;
logic [5:0] shift_amount_l;

always_comb begin
    case (byte_index_i)
    2'b00: begin
        byte_l = data_i[31:24];
        shift_amount_l = 6'd8;
    end
    2'b01: begin
        byte_l = data_i[7:0];
        shift_amount_l = 6'd32;
    end
    2'b10: begin
        byte_l = data_i[15:8];
        shift_amount_l = 6'd24;
    end
    2'b11: begin
        byte_l = data_i[23:16];
        shift_amount_l = 6'd16;
    end
end

//de_ad_be_ef

assign byte_o = byte_l;
assign shift_amount_o = shift_amount_l;

endmodule
