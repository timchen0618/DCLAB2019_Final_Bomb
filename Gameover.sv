module Gameover(
	//input
	input clk,
	input reset,
	input [255:0] i_explode,
	input [7:0] p1_cor,
	input [7:0] p2_cor,
	//output
	output logic [2:0] gameover_state
	);
		
	
	parameter NONE = 3'd0;
	parameter GAMEOVER = 3'd1;
	parameter P1 = 3'd2;
	parameter P2 = 3'd3;
	parameter FINISH = 3'd4;

	parameter P1_WIN = 1'd0;
	parameter P2_WIN = 1'd1;

	logic [6:0] gameover_ctr, gameover_ctr_nxt;
	logic [2:0] gameover_state_nxt;
	logic winner, winner_nxt;

	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			winner <= 1'd0;
			gameover_state <= 3'd0;
			gameover_ctr <= 7'd0;
		end else begin
			winner <= winner_nxt;
			gameover_state <= gameover_state_nxt;
			gameover_ctr <= gameover_ctr_nxt;
		end
	end

	always_comb begin
		gameover_state_nxt = gameover_state;
		winner_nxt = winner;
		gameover_ctr_nxt = gameover_ctr;

		case(gameover_state)
			NONE:
			begin
				if (i_explode[p1_cor] == 1'd1) begin
					gameover_state_nxt = GAMEOVER;
					winner_nxt = P2_WIN;
				end
				if (i_explode[p2_cor] == 1'd1) begin
					gameover_state_nxt = GAMEOVER;
					winner_nxt = P1_WIN;
				end
			end
			GAMEOVER:
			begin
				if(gameover_ctr >= 7'd60) begin
					if(winner == P1_WIN) begin
						gameover_state_nxt = P1;
					end
					else begin
						gameover_state_nxt = P2;
					end
					gameover_ctr_nxt = 0;
				end
				else gameover_ctr_nxt = gameover_ctr + 7'd1;
			end
			P1:
			begin
				if(gameover_ctr >= 7'd90) begin
					gameover_state_nxt = FINISH;
				end
				else gameover_ctr_nxt = gameover_ctr + 7'd1;
			end
			P2:
			begin
				if(gameover_ctr >= 7'd90) begin
					gameover_state_nxt = FINISH;
				end
				else gameover_ctr_nxt = gameover_ctr + 7'd1;
			end
			FINISH:
			begin
				gameover_state_nxt = gameover_state;
			end
			default:
			begin
				gameover_state_nxt = gameover_state;
				winner_nxt = winner;
				gameover_ctr_nxt = gameover_ctr;
			end
		endcase
	end

endmodule // Gameover