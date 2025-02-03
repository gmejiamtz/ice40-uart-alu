module elastic_pipeline
 #(parameter [31:0] width_p = 10
  )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o

  ,output [0:0] valid_o
  ,output [width_p - 1:0] data_o
  ,input [0:0] yumi_i
  );
	logic [0:0] ready_l,valid_l;
	logic [width_p-1:0] data_l;
	always_ff @(posedge clk_i) begin
		if (reset_i) begin
			ready_l <= 1'b1;
			valid_l <= 1'b0;
			data_l <= {width_p{1'b0}};
		end else if(ready_o & valid_i) begin
			ready_l <= 1'b0;
			valid_l <= 1'b1;
			data_l <= data_i;
		end else if (valid_o & yumi_i) begin
			ready_l <= 1'b1;
			valid_l <= 1'b0;
		end
	end
	assign data_o = data_l;
	assign ready_o = ready_l;
	assign valid_o = valid_l;
endmodule
