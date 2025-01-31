module shift_8 (
    input logic clk_i,
    input logic rst,
    input logic en_i,
    input logic [7:0] data_i,
    output logic [31:0] data_o
);
    always_ff @(posedge clk_i) begin
        if(rst) begin
            data_o <= '0;
        end else if (en_i) begin
            data_o <= {data_o[23:0], data_i};
        end
    end
endmodule
