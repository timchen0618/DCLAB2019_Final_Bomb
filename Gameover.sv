module Gameover(
	//input
	input clk,
	input reset,
	input [255:0] i_explode,
	input [7:0] p1_cor,
	input [7:0] p2_cor,
	//output
	output logic gameover,
	output logic [1:0] winner
	);
		
	parameter NONE = 2'd0;
	parameter P1 = 2'd1;
	parameter P2 = 2'd2;
	parameter TIE = 2'd3;

	logic gameover_nxt;
	logic [1:0] winner_nxt;

	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			 gameover <= 1'd0;
			 winner <= 2'd0;
		end else begin
			 gameover <= gameover_nxt;
			 winner <= winner_nxt;
		end
	end

	always_comb begin
		if(i_explode[p1_cor] == 1'd1 && i_explode[p2_cor] == 1'd1) begin //die at the same time
			gameover_nxt = 1'd1;
			winner_nxt = TIE;
		end
		else if(i_explode[p1_cor] == 1'd1) begin //P1 die
			gameover_nxt = 1'd1;
			winner_nxt = P2;
		end
		else if(i_explode[p2_cor] == 1'd1) begin //P2 die
			gameover_nxt = 1'd1;
			winner_nxt = P1;
		end
		else begin
			gameover_nxt = 1'd0;
			winner_nxt = NONE;
		end
	end

endmodule // Gameover