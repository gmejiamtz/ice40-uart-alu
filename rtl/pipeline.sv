module pipeline
 #(parameter [31:0] width_p = 10
  )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o

  ,output [0:0] valid_o
  ,output [width_p - 1:0] data_o
  ,input [0:0] ready_i
  );
	logic [0:0] ready_l,valid_l;
	logic [width_p-1:0] data_l;
    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            data_l <= '0;
        end else if(ready_o & valid_i) begin
            data_l <= data_i;
        end
    end

    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            valid_l <= '0;
        end else if (ready_o) begin
            valid_l <= ready_o & valid_i;
        end
    end

	assign data_o = data_l;
	assign valid_o = valid_l;
	assign ready_o = ready_i | ~valid_o;
endmodule
