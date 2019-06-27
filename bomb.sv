module bomb(
	input clk,
	input reset,
	input [1:0] p1_bomb_len, 
	input [1:0]	p2_bomb_len,
	// input [2:0] p1_bomb_cap, p2_bomb_cap,
	input [7:0] p1_cor, p2_cor,
	input p1_put, 
	input p2_put,
	input [2:0] wall_grid [0:255],
	output logic [2:0] bomb_tile [0:255],
	output logic [255:0] explode,
	output [2:0] bomb_num_p1,
	output [2:0] bomb_num_p2,
	output [2:0] display1,
	output display2,
	output display3,
	output display4,
	output [5:0] bomb_p1_ctr_0,
	output [3:0] bomb_p1_o,
	output logic [3:0] p1_put_ctr,
	output logic [255:0] bomb_un_grid
);	

// states
parameter EMPTY 		= 3'd0;
parameter READY_EXP 	= 3'd1;
parameter BOMB_UN 		= 3'd2;
parameter EXP_UP 		= 3'd3;
parameter EXP_DOWN 		= 3'd4;
parameter EXP_LEFT 		= 3'd5;
parameter EXP_RIGHT 	= 3'd6;
parameter EXP_CEN	 	= 3'd7;

// bomb put by which
parameter P1 	= 1'b0;
parameter P2 	= 1'b1;

// WALL
parameter EMPTY_WALL = 3'd0;


// integers
integer ii, i, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14;

logic [2:0] bomb_tile_next [0:255];
logic [2:0] bomb_tile_prev_r [0:255];
logic [2:0] bomb_tile_prev_w [0:255];

logic [1:0] bomb_len_mem [0:255];
logic [1:0] bomb_len_mem_next [0:255];


logic [255:0] bomb_put_by_which; // 0 for p1, 1 for p2;
logic [5:0] bomb_ctr [0:255];
logic [5:0] bomb_ctr_next[0:255];
logic [2:0] display_w1, display_r1;
logic display_w2, display_r2;
logic display_w3, display_r3;
logic display_w4, display_r4;

//for bomb on grid
logic [3:0] bomb_p1, bomb_p2, bomb_p1_nxt, bomb_p2_nxt;
logic [5:0] bomb_p1_ctr [0:3];
logic [5:0] bomb_p2_ctr [0:3]; 
logic [5:0] bomb_p1_ctr_nxt [0:3];
logic [5:0] bomb_p2_ctr_nxt [0:3]; 

// P1_PUT_COUNTER
logic [3:0] p1_put_ctr_next;


assign bomb_num_p1 = bomb_p1[0] + bomb_p1[1] + bomb_p1[2] + bomb_p1[3];
assign bomb_num_p2 = bomb_p2[0] + bomb_p2[1] + bomb_p2[2] + bomb_p2[3];

assign bomb_p1_ctr_0 = bomb_p1[0];
assign bomb_p1_o = bomb_p1;
  
assign display1 = display_r1;
assign display2 = display_r2;
assign display3 = display_r3;
assign display4 = display_r4;

	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			for(i2 = 0; i2 < 256; i2 = i2 + 1) begin
				bomb_tile[i2] 			<= 0;
				bomb_ctr[i2] 			<= 0;
				bomb_tile_prev_r[i2] 	<= 0;
				bomb_len_mem[i2] 		<= 0;
			end

			for(i7 = 0; i7 < 4; i7 = i7+1) begin
				bomb_p1_ctr[i7] 	<=	0;
				bomb_p2_ctr[i7] 	<=	0;
			end

			display_r1			<= 0;
			display_r2			<= 0;
			display_r3			<= 0;
			display_r4			<= 0;
			bomb_p1 			<= 0;
			bomb_p2 			<= 0;
			p1_put_ctr 			<= 0;
		end 
		else begin
			for(i3 = 0; i3 < 256; i3 = i3 + 1) begin
				bomb_tile[i3] 			<= bomb_tile_next[i3];
				bomb_ctr[i3] 			<= bomb_ctr_next[i3];
				bomb_tile_prev_r[i3] 	<= bomb_tile_prev_w[i3];
				bomb_len_mem[i3]  		<= bomb_len_mem_next[i3];
			end

			for(i8 = 0; i8 < 4; i8 = i8 + 1)begin
				bomb_p1_ctr[i8] 	<= bomb_p1_ctr_nxt[i8];
				bomb_p2_ctr[i8] 	<= bomb_p2_ctr_nxt[i8];
			end

			display_r1 			<= display_w1;
			display_r2 			<= display_w2;
			display_r3 			<= display_w3;
			display_r4 			<= display_w4;
			bomb_p1 			<= bomb_p1_nxt;
			bomb_p2 			<= bomb_p2_nxt;
			p1_put_ctr  		<= p1_put_ctr_next;
		end
	end

	always_comb begin 

		for(i12 = 0; i12 < 256 ; i12 = i12 + 1) begin 
			bomb_un_grid[i12] = 0;
			if(bomb_tile[i12] == BOMB_UN) bomb_un_grid[i12] = 1;
		end
	end

	always_comb begin 
		p1_put_ctr_next = p1_put_ctr;
		if(p1_put) begin
			if(p1_put_ctr < 15) begin
				p1_put_ctr_next = p1_put_ctr + 1;
			end 
		end
	end

	always_comb begin   // outputing EXPLODE or not
		for(ii = 0; ii < 256 ; ii = ii + 1) begin
			if(bomb_tile[ii] >= 3'd3) 	explode[ii] = 1;
			else 						explode[ii] = 0;
		end
	end

	always_comb begin // recording PREVIOUS BOMB TILE
		for(i9 = 0; i9 < 256 ; i9 = i9 + 1) begin
			bomb_tile_prev_w[i9] = bomb_tile[i9];
		end
	end

	always_comb begin
		for(i11 = 0; i11 < 256; i11 = i11 + 1) begin
			bomb_len_mem_next[i11] = bomb_len_mem[i11];
			if(i11 == p1_cor && p1_put) bomb_len_mem_next[i11] = p1_bomb_len;
			if(i11 == p2_cor && p2_put) bomb_len_mem_next[i11] = p2_bomb_len;
		end
	end

	always_comb begin 
		bomb_p1_nxt = bomb_p1;
		bomb_p2_nxt = bomb_p2;
		bomb_p1_ctr_nxt = bomb_p1_ctr;
		bomb_p2_ctr_nxt = bomb_p2_ctr;
		
		if(p1_cor == p2_cor) begin
			if(p1_put) begin 
				if(bomb_p1[0] == 0) bomb_p1_nxt[0] = 1;
				else if (bomb_p1[1] == 0) bomb_p1_nxt[1] = 1;
				else if (bomb_p1[2] == 0) bomb_p1_nxt[2] = 1;
				else if (bomb_p1[3] == 0) bomb_p1_nxt[3] = 1;
				else bomb_p1_nxt = bomb_p1;
			end

			else if(p2_put) begin 
				if(bomb_p2[0] == 0) bomb_p2_nxt[0] = 1;
				else if (bomb_p2[1] == 0) bomb_p2_nxt[1] = 1;
				else if (bomb_p2[2] == 0) bomb_p2_nxt[2] = 1;
				else if (bomb_p2[3] == 0) bomb_p2_nxt[3] = 1;
				else bomb_p2_nxt = bomb_p2;
			end
		end
		else begin
			if(p1_put) begin 
				if(bomb_p1[0] == 0) bomb_p1_nxt[0] = 1;
				else if (bomb_p1[1] == 0) bomb_p1_nxt[1] = 1;
				else if (bomb_p1[2] == 0) bomb_p1_nxt[2] = 1;
				else if (bomb_p1[3] == 0) bomb_p1_nxt[3] = 1;
				else bomb_p1_nxt = bomb_p1;
			end

			if(p2_put) begin 
				if(bomb_p2[0] == 0) bomb_p2_nxt[0] = 1;
				else if (bomb_p2[1] == 0) bomb_p2_nxt[1] = 1;
				else if (bomb_p2[2] == 0) bomb_p2_nxt[2] = 1;
				else if (bomb_p2[3] == 0) bomb_p2_nxt[3] = 1;
				else bomb_p2_nxt = bomb_p2;
			end
		end
		

		for(i5 = 0; i5 < 4 ; i5 = i5 + 1) begin
			if(bomb_p1[i5] == 1) begin 
				if(bomb_p1_ctr[i5] >= 6'd60) begin 
					bomb_p1_ctr_nxt[i5] = 0;
					bomb_p1_nxt[i5] = 0;
				end
				else bomb_p1_ctr_nxt[i5] = bomb_p1_ctr[i5] + 1;
			end
		end
		for(i6 = 0; i6 < 4 ; i6 = i6 + 1) begin
			if(bomb_p2[i6] == 1) begin 
				if(bomb_p2_ctr[i6] >= 6'd60) begin 
					bomb_p2_ctr_nxt[i6] = 0;
					bomb_p2_nxt[i6] = 0;
				end
				else bomb_p2_ctr_nxt[i6] = bomb_p2_ctr[i6] + 1;
			end
		end
		
	end

	always_comb begin 
		display_w1 = 0;
		display_w2 = 0;
		display_w3 = 0;
		display_w4 = 0;
		for(i13 = 0; i13 < 256 ; i13 = i13 + 1) begin
			bomb_tile_next[i13] 	= bomb_tile[i13];
			bomb_ctr_next[i13]	= bomb_ctr[i13];
		end

		
		
		// considering p1 or p2 putting bomb, not yet setting ready explode
		for(i = 0; i < 256 ; i = i + 1) begin
			// handling setting bomb
			if(i == p1_cor && p1_put ) begin// if p1 set_bomb
				bomb_tile_next[i] 	= BOMB_UN;
				bomb_put_by_which[i] = 0;
				
			end
			else if(i == p2_cor && p2_put ) begin// if p2 set_bomb
				bomb_tile_next[i] = BOMB_UN;
				bomb_put_by_which[i] = 1;
				
			end
			else begin 
				bomb_put_by_which[i] 	= 1'bZ;

			end

			// unexploded bomb, explode after two seconds
			if(bomb_tile[i] == BOMB_UN) begin
				if(bomb_ctr[i] >= 6'd60) begin
					bomb_tile_next[i] = EXP_CEN;
					bomb_ctr_next[i] = 0;
				end
				else bomb_ctr_next[i] = bomb_ctr[i] + 1;
			end

			// explode animation display for one seconds
			if(bomb_tile[i] >= EXP_UP) begin
				if(bomb_ctr[i] >= 6'd17) begin
					bomb_tile_next[i] = EMPTY;
					bomb_ctr_next[i] = 0;
					if(i == 4) begin 
						display_w1 = bomb_tile[i];
					end
				end
				else bomb_ctr_next[i] = bomb_ctr[i] + 1;
			end

			// handling setting parameters to explode
			if(bomb_tile[i] == EXP_CEN && bomb_ctr[i] == 6'd0) begin
				case(bomb_len_mem[i]) 
					2'd0: begin
						if((i+1) % 16 != 0) begin 
							bomb_tile_next[i+1] = EXP_RIGHT; 	// not the rightmost column
							//display_w1 = 1;
						end 
						if(i % 16 != 0) begin 
							bomb_tile_next[i-1] = EXP_LEFT;  	// not the leftmost column
							display_w2 = 1;
						end 
						if(i > 15) begin
							bomb_tile_next[i-16] = EXP_UP; 		// not the first row
							display_w3 = 1;
						end 
						if(i < 240)	begin
							bomb_tile_next[i+16] = EXP_DOWN; 	// not the last row
							display_w4 = 1;
						end 
						
					end	
					2'd1: begin
						if((i+1) % 16 != 0) begin 
							bomb_tile_next[i+1] = EXP_RIGHT; 	// not the rightmost column
							if(i % 16 != 14 && wall_grid[i+1] == EMPTY_WALL ) bomb_tile_next[i+2] = EXP_RIGHT; // not the rightmost two columns
						end		
						if(i % 16 != 0) begin 
							bomb_tile_next[i-1] = EXP_LEFT;  	// not the leftmost column
							if(i % 16 != 1 && wall_grid[i-1] == EMPTY_WALL) bomb_tile_next[i-2] = EXP_LEFT;  	// not the leftmost two columns
						end				
						if(i > 15) begin 
							bomb_tile_next[i-16] = EXP_UP; 		// not the first row
							if(i > 31 && wall_grid[i-16] == EMPTY_WALL) bomb_tile_next[i-32] = EXP_UP; 		// not the first two rows
						end 										
						if(i < 240)	begin 
							bomb_tile_next[i+16] = EXP_DOWN; 	// not the last row
							if(i < 224 && wall_grid[i+16] == EMPTY_WALL)	bomb_tile_next[i+32] = EXP_DOWN; 	// not the last two rows	  
						end									
					end	
					2'd2: begin
						if((i+1) % 16 != 0) begin 
							bomb_tile_next[i+1] = EXP_RIGHT; 	// not the rightmost column
							if(i % 16 != 14 && wall_grid[i+1] == EMPTY_WALL) begin 
								bomb_tile_next[i+2] = EXP_RIGHT;	// not the rightmost two columns
								if(i % 16 != 13 && wall_grid[i+2] == EMPTY_WALL) bomb_tile_next[i+3] = EXP_RIGHT;	// not the rightmost three columns
							end 
						end								
						if(i % 16 != 0) begin 
							bomb_tile_next[i-1] = EXP_LEFT;  	// not the leftmost column
							if(i % 16 != 1 && wall_grid[i-1] == EMPTY_WALL) begin 
								bomb_tile_next[i-2] = EXP_LEFT;  	// not the leftmost two columns
								if(i % 16 != 2 && wall_grid[i-2] == EMPTY_WALL) begin 
									bomb_tile_next[i-3] = EXP_LEFT;  	// not the leftmost three columns
								end
							end
						end									
						if(i > 15) begin 
							bomb_tile_next[i-16] = EXP_UP; 		// not the first row
							if(i > 31 && wall_grid[i-16] == EMPTY_WALL) begin 
								bomb_tile_next[i-32] = EXP_UP; 		// not the first two rows
								if(i > 47 && wall_grid[i-32] == EMPTY_WALL) bomb_tile_next[i-48] = EXP_UP; 		// not the first three rows
							end
						end																				
						if(i < 240)	begin 
							bomb_tile_next[i+16] = EXP_DOWN; 	// not the last row
							if(i < 224 && wall_grid[i+16] == EMPTY_WALL)	begin 
								bomb_tile_next[i+32] = EXP_DOWN; 	// not the last two rows
								if(i < 208 && wall_grid[i+32] == EMPTY_WALL)	bomb_tile_next[i+48] = EXP_DOWN; 	// not the last three rows
							end
						end										
																
						
					end	
					2'd3: begin
						if((i+1) % 16 != 0) begin 
							bomb_tile_next[i+1] = EXP_RIGHT; 	// not the rightmost column
							if(i % 16 != 14 && wall_grid[i+1] == EMPTY_WALL) begin 
								bomb_tile_next[i+2] = EXP_RIGHT;	// not the rightmost two columns
								if(i % 16 != 13 && wall_grid[i+2] == EMPTY_WALL)  begin 
									bomb_tile_next[i+3] = EXP_RIGHT;	// not the rightmost three columns
									if(i % 16 != 12 && wall_grid[i+3] == EMPTY_WALL) bomb_tile_next[i+4] = EXP_RIGHT;	// not the rightmost four columns
								end
							end 
						end								
						if(i % 16 != 0) begin 
							bomb_tile_next[i-1] = EXP_LEFT;  	// not the leftmost column
							if(i % 16 != 1 && wall_grid[i-1] == EMPTY_WALL) begin 
								bomb_tile_next[i-2] = EXP_LEFT;  	// not the leftmost two columns
								if(i % 16 != 2 && wall_grid[i-2] == EMPTY_WALL) begin 
									bomb_tile_next[i-3] = EXP_LEFT;  	// not the leftmost three columns
									if(i % 16 != 3 && wall_grid[i-3] == EMPTY_WALL) bomb_tile_next[i-4] = EXP_LEFT;  	// not the leftmost four columns
								end
							end
						end									
						if(i > 15) begin 
							bomb_tile_next[i-16] = EXP_UP; 		// not the first row
							if(i > 31 && wall_grid[i-16] == EMPTY_WALL) begin 
								bomb_tile_next[i-32] = EXP_UP; 		// not the first two rows
								if(i > 47 && wall_grid[i-32] == EMPTY_WALL) begin 
									bomb_tile_next[i-48] = EXP_UP; 		// not the first three rows
									if(i > 63 && wall_grid[i-48] == EMPTY_WALL) bomb_tile_next[i-64] = EXP_UP; 		// not the first four rows	
								end 
							end
						end																				
						if(i < 240)	begin 
							bomb_tile_next[i+16] = EXP_DOWN; 	// not the last row
							if(i < 224 && wall_grid[i+16] == EMPTY_WALL)	begin 
								bomb_tile_next[i+32] = EXP_DOWN; 	// not the last two rows
								if(i < 208 && wall_grid[i+32] == EMPTY_WALL) begin 
									bomb_tile_next[i+48] = EXP_DOWN; 	// not the last three rows
									if(i < 192 && wall_grid[i+48] == EMPTY_WALL)	bomb_tile_next[i+64] = EXP_DOWN; 	// not the last four rows
								end	
							end
						end
					end	
				endcase // p1_bomb_len
			end
			// if(bomb_tile[i] >= EXP_UP && bomb_tile_prev_r[i] == BOMB_UN) begin 
			// 	bomb_tile_next[i] = EXP_CEN;
			// end
		end
		
		for(i14 = 0; i14 < 256; i14 = i14 + 1) begin
			if(bomb_tile[i14] >= EXP_UP && bomb_tile_prev_r[i14] == BOMB_UN) begin 
				bomb_tile_next[i14] = EXP_CEN;
			end
		end
	end

endmodule