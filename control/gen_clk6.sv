module gen_clk6 (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	output clk_o
);

	logic [2:0] ctr_w, ctr_r;
	logic state, next_state;
	parameter POS = 0;
	parameter NEG = 1;
	assign clk_o = state;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			ctr_r <= 0;
			state <= 1;
		end else begin
			ctr_r <= ctr_w;
			state <= next_state;
		end
	end

	always @* begin 
		next_state = state;
		ctr_w = ctr_r + 1;

		if(ctr_r == 4) begin
			next_state = ~state;
			ctr_w = 0;
		end
	end 

endmodule