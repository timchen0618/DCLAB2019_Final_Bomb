module Picture_Output(
	input clk,
	input reset,
	input [2:0] gadget_grid [0:255],
	input [2:0] bomb_grid [0:255],
	input [2:0] wall_grid [0:255],
	output [3:0] occ_grid [0:255]
);
	// occ_grid
	parameter OCC_NONE 			= 5'd0;
	parameter OCC_LOTION 		= 5'd1; // sth that can add bomb length
	parameter OCC_BOMB 			= 5'd2; // unxploded bomb
	parameter OCC_ADD_BOMB 		= 5'd3; // thing that can add bomb capacity
	parameter OCC_CEN 			= 5'd4;  // the center of the explosion 
	parameter OCC_UP 			= 5'd5;  
	parameter OCC_DOWN 			= 5'd6;  
	parameter OCC_LEFT 			= 5'd7;
	parameter OCC_RIGHT 		= 5'd8;
	parameter OCC_WALL_ABLE_1 	= 5'd9;
	parameter OCC_WALL_ABLE_2 	= 5'd10;
	parameter OCC_WALL_UN_1		= 5'd11;
	parameter OCC_WALL_UN_2		= 5'd12;

	// wall_grid
	parameter EMPTY_WALL	= 3'd0;
	parameter ABLE_WALL_1 	= 3'd1;
	parameter ABLE_WALL_2	= 3'd2;
	parameter UN_WALL_1		= 3'd3;
	parameter UN_WALL_2		= 3'd4;	

	// gadget_grid
	parameter EMPTY_G 			= 3'd0;
	parameter LOTION 			= 3'd1;
	parameter ADD_BOMB 			= 3'd2;
	parameter HIDDEN_LOTION		= 3'd3;
	parameter HIDDEN_ADD_BOMB 	= 3'd4;

	// 	bomb_grid
	parameter EMPTY 		= 3'd0;
	parameter READY_EXP 	= 3'd1;
	parameter BOMB_UN 		= 3'd2;
	parameter EXP_UP 		= 3'd3;
	parameter EXP_DOWN 		= 3'd4;
	parameter EXP_LEFT 		= 3'd5;
	parameter EXP_RIGHT 	= 3'd6;
	parameter EXP_CEN	 	= 3'd7;

	logic [3:0] occ_grid_next [0:255];

	integer i;
	integer i1, i2;

	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			for(i1 = 0;i1 < 256; i1 = i1 + 1) begin
				occ_grid[i1] <= 0;
			end
		end 
		else begin
			for(i2 = 0;i2 < 256; i2 = i2 + 1) begin
				occ_grid[i2] <= occ_grid_next[i2];
			end
		end
	end

	always_comb begin
		for(i = 0;i < 256; i = i + 1) begin
			occ_grid_next[i] = occ_grid[i];
			case(bomb_grid[i])
				BOMB_UN: occ_grid_next[i] = OCC_BOMB;
				EXP_UP: occ_grid_next[i] = OCC_UP;
				EXP_DOWN: occ_grid_next[i] = OCC_DOWN;
				EXP_LEFT: occ_grid_next[i] = OCC_LEFT;
				EXP_RIGHT: occ_grid_next[i] = OCC_RIGHT;
				EXP_CEN: occ_grid_next[i] = OCC_CEN;
				EMPTY: 
				begin 
					if(gadget_grid[i] == LOTION) occ_grid_next[i] = OCC_LOTION;
					else if(gadget_grid[i] == ADD_BOMB) occ_grid_next[i] = OCC_ADD_BOMB;
					if(wall_grid[i] == ABLE_WALL_1 || wall_grid[i] == ABLE_WALL_2) begin 
						if(wall_grid[i] == ABLE_WALL_1) occ_grid_next[i] = OCC_WALL_ABLE_1;
						else occ_grid_next[i] = OCC_WALL_ABLE_2;
					end 
					else if(wall_grid[i] == UN_WALL_1 || wall_grid[i] == UN_WALL_2) begin 
						if(wall_grid[i] == UN_WALL_1 ) occ_grid_next[i] = OCC_WALL_UN_1;
						else if(wall_grid[i] == UN_WALL_2) occ_grid_next[i] = OCC_WALL_UN_2;
					end 
					if(wall_grid[i] == EMPTY_WALL && gadget_grid[i] == EMPTY_G) occ_grid_next[i] = OCC_NONE;
				end
			endcase // bomb_grid[i]
			if(wall_grid[i] == UN_WALL_1 || wall_grid[i] == UN_WALL_2) begin 
				if(wall_grid[i] == UN_WALL_1 ) occ_grid_next[i] = OCC_WALL_UN_1;
				else if(wall_grid[i] == UN_WALL_2) occ_grid_next[i] = OCC_WALL_UN_2;
			end 
		end
	end

endmodule // Picture_Output

