module Grid (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	// input p1_alive,
	// input p2_alive,
	input p1_set, //player 1 set bomb
	input p2_set, //player 2 set bomb
	input [7:0] p1_cor, 
	input [7:0] p2_cor,
	// input [2:0] p1_bomb_len, //player 1 bomb len (1~7)
	// input [2:0] p2_bomb_len, //player 2 bomb len (1~7)
	output logic [4:0] occ_grid [0:255],
	output [255:0] wall_grid_out ,
	output [2:0] p1_bomb_cap_out,
	output [2:0] p2_bomb_cap_out,
	output [2:0] p1_bomb_unexp_num_out,
	output [2:0] p2_bomb_unexp_num_out,
	output logic game_over
);
	

	//states for grid -> for determining bomb explosion
	parameter EMPTY = 3'd0;
	//when p1 or p2 set bomb
	parameter BOMB_CEN_0 = 3'd1; 
	parameter BOMB_CEN_1 = 3'd2; 
	parameter BOMB_CEN_2 = 3'd3;
	parameter BOMB_CEN_3 = 3'd4;
	parameter READY_EXPLODE = 3'd5;
	parameter EXPLODE_0 = 3'd6;
	parameter EXPLODE_1 = 3'd7;
	
	//states for occ_grid ->display 
	//order priority: UP->RIGHT->DOWN->LEFT
	parameter OCC_NONE = 5'd0;
	parameter OCC_LOTION = 5'd1; // sth that can add bomb length
	parameter OCC_BOMB = 5'd2; // unxploded bomb
	parameter OCC_ADD_BOMB = 5'd3; // thing that can add bomb capacity
	parameter OCC_CEN = 5'd4;  // the center of the explosion 
	parameter OCC_UP = 5'd5;  
	parameter OCC_DOWN = 5'd6;  
	parameter OCC_LEFT = 5'd7;
	parameter OCC_RIGHT = 5'd8;
	parameter OCC_WALL_ABLE = 5'd9;
	parameter OCC_WALL_UN = 5'd10;

	//states with gadget and exploding bomb (displaying flushing water)
	parameter OCC_ADD_BOMB_UP = 5'd11;
	parameter OCC_ADD_BOMB_DOWN = 5'd12;
	parameter OCC_ADD_BOMB_LEFT = 5'd13;
	parameter OCC_ADD_BOMB_RIGHT = 5'd14;
	parameter OCC_LOTION_UP = 5'd15;
	parameter OCC_LOTION_DOWN = 5'd16;
	parameter OCC_LOTION_LEFT = 5'd17;
	parameter OCC_LOTION_RIGHT = 5'd18;
	
	//gadget num (could be adjust)
	parameter BOMB_NUM_MAX = 2'd3;
	parameter LOTION_NUM_MAX = 2'd3; 

	// explosion direction
	parameter UP = 2'd0;
	parameter DOWN = 2'd1;
	parameter LEFT = 2'd2;
	parameter RIGHT = 2'd3;

	logic [255:0] wall_grid, wall_grid_next ;  // 0: no wall, 1: wall -> for Tim 
	// logic [4:0] occ_grid [0:255] ;
	logic [4:0] occ_grid_nxt [0:255];
	logic [1:0] add_bomb_num, add_bomb_num_nxt, add_lotion_num, add_lotion_num_nxt;
	// logic game_state, game_state_nxt;
	logic [2:0] p1_bomb_unexp_num, p2_bomb_unexp_num, p1_bomb_unexp_num_next, p2_bomb_unexp_num_next;  // the number of unexploded bomb on the scene
 
 	//bool
	logic need_add_bomb;
	logic need_add_lotion;
	logic [7:0] add_bomb_loc, add_lotion_loc; 

	// player status
	logic [1:0] p1_bomb_len, p2_bomb_len, p1_bomb_len_next, p2_bomb_len_next; // the length of the bombing -> 0-3 (1-4)
	logic [2:0] p1_bomb_cap, p2_bomb_cap, p1_bomb_cap_next, p2_bomb_cap_next; // the bomb capacity available for players

	// game status 
	logic game_over_next; 
	logic p1_win, p2_win, p1_win_next, p2_win_next;

	// assign output


	//assign bool
	assign need_add_bomb = (add_bomb_num != BOMB_NUM_MAX);
	assign need_add_lotion = (add_lotion_num != LOTION_NUM_MAX);
	assign wall_grid_out = wall_grid;
	assign p1_bomb_cap_out = p1_bomb_cap;
	assign p2_bomb_cap_out = p2_bomb_cap;
	assign p1_bomb_unexp_num_out = p1_bomb_unexp_num;
	assign p2_bomb_unexp_num_out = p2_bomb_unexp_num;

	// assign make_bomb = (bomb_num < BOMB_NUM_MAX);
	// assign make_lotion = (lotion_num < LOTION_NUM_MAX);
	//integer idx;

	integer ii;
	integer i;
	integer idx;
	integer index;
	integer k;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			//integer ii;
			for(ii=0; ii < 256; ii = ii +1) begin

				//set grid background
				//unable wall n able wall
				if(ii[3:0] < 4'd7 && ii < 8'd128)begin //upper-left
					if(ii > 8'd7)begin
						if(ii[1:0] == 2'd1 && ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_UN;
						else if(ii > 0) begin
							if(ii[1:0] ==2'd0 && ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_ABLE;
							else if(ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_ABLE;
							else occ_grid[ii] <= OCC_NONE; 
						end
						else occ_grid[ii] <= OCC_NONE;
					end
					else begin //first row
						if(ii > 8'd1) occ_grid[ii] <= OCC_WALL_ABLE;
						else occ_grid[ii] <= OCC_NONE;
					end 
				end 
				else if(ii[3:0] > 4'd8 && ii < 8'd128)begin //upper-right
					if(ii[1:0] == 2'd0 && ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_UN; 
					else if (ii[1:0] == 2'd1 && ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_ABLE;
					else if (ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_ABLE; 
					else occ_grid[ii] <= OCC_NONE;
				end 
				else if(ii[3:0] < 4'd7 && ii > 8'd128) begin //down-left
					if(ii[1:0] == 2'd0 && ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_UN;
					else if (ii[1:0] == 2'd1 && ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_ABLE;
					else if(ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_ABLE;
					else occ_grid[ii] <= OCC_NONE;
				end
				else if(ii[3:0] > 4'd8 && ii > 8'd128) begin //down-right
					if(ii[1:0] == 2'd1 && ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_UN;
					else if (ii < 8'd240) begin
						if(ii[1:0] == 2'd0 && ii[5] == 2'd1) occ_grid[ii] <= OCC_WALL_ABLE;
						else if(ii[5] == 2'd0) occ_grid[ii] <= OCC_WALL_ABLE;  
					end
					else occ_grid[ii] <= OCC_NONE;
				end
				else occ_grid[ii] <= OCC_NONE;

				//
				//occ_grid[ii]			<= 0;
				//wall_grid[ii] 			<= 0;
		    end
		    add_bomb_num  				<= 3;
		    add_lotion_num 				<= 3;
		    p1_bomb_unexp_num  			<= 0;
		    p2_bomb_unexp_num			<= 0;
		    p1_bomb_len 				<= 0;
		    p2_bomb_len 				<= 0;
		    p1_bomb_cap 				<= 1;
		    p2_bomb_cap 				<= 1;
		    game_over 					<= 0;
		    p1_win 						<= 0;
		    p2_win     					<= 0;
			
		end 
		else begin
			//integer ii;
			for(ii=0; ii < 256; ii = ii +1) begin
				occ_grid[ii]			<= occ_grid_nxt[ii];
				wall_grid[ii]  			<= wall_grid_next[ii];
		    end
			add_bomb_num 				<= add_bomb_num_nxt;
			add_lotion_num 				<= add_lotion_num_nxt;
			p1_bomb_unexp_num 			<= p1_bomb_unexp_num_next;
			p2_bomb_unexp_num 			<= p2_bomb_unexp_num_next;
			p1_bomb_len 				<= p1_bomb_len_next;
			p2_bomb_len 				<= p2_bomb_len_next;
			p1_bomb_cap 				<= p1_bomb_cap_next;
		    p2_bomb_cap 				<= p2_bomb_cap_next;
		    game_over 					<= game_over_next;
		    p1_win 						<= p1_win_next;
		    p2_win 						<= p2_win_next;
		end
	end

	always_comb begin 
		for(idx=0; idx <256; idx = idx +1) begin
			if(occ_grid[idx] == OCC_WALL_ABLE || occ_grid[idx] == OCC_WALL_UN) wall_grid_next[idx] = 1;
			else wall_grid_next[idx] = 0;
	    end	
	end

	always_comb begin // determine player status
		p1_bomb_cap_next = p1_bomb_cap;
		p2_bomb_cap_next = p2_bomb_cap;
		p1_bomb_len_next = p1_bomb_len;
		p2_bomb_len_next = p2_bomb_len;

		if(occ_grid[p1_cor] == OCC_ADD_BOMB && p1_bomb_cap < 4) p1_bomb_cap_next = p1_bomb_cap + 1 ;
		if(occ_grid[p2_cor] == OCC_ADD_BOMB && p2_bomb_cap < 4) p2_bomb_cap_next = p2_bomb_cap + 1 ;
		if(occ_grid[p1_cor] == OCC_LOTION && p1_bomb_len < 3) p1_bomb_len_next = p1_bomb_len + 1 ;
		if(occ_grid[p2_cor] == OCC_LOTION && p2_bomb_len < 3) p2_bomb_len_next = p2_bomb_len + 1 ;

	end

	always_comb begin  // determine game status
		p1_win_next = p1_win; 
		p2_win_next = p2_win;
		game_over_next = game_over;
		

		case(occ_grid[p1_cor])
			OCC_CEN: 
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_UP:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_DOWN:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_RIGHT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_LEFT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_UP:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_DOWN:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_LEFT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_RIGHT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_UP:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_DOWN:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_RIGHT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_LEFT:
			begin
				p2_win_next = 1;
				game_over_next = 1;
			end
		endcase

		case(occ_grid[p2_cor])
			OCC_CEN: 
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_UP:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_DOWN:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_RIGHT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_LEFT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_UP:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_DOWN:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_LEFT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_ADD_BOMB_RIGHT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_UP:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_DOWN:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_RIGHT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
			OCC_LOTION_LEFT:
			begin
				p1_win_next = 1;
				game_over_next = 1;
			end
		endcase
	end

	always_comb begin //for occ states

		add_bomb_num_nxt = add_bomb_num;
		add_lotion_num_nxt = add_lotion_num;
		for(k=0; k < 256; k = k+1) begin
			occ_grid_nxt[k] = occ_grid[k];
		end

		//keep fixed num of add_bomb and add_lotion on the grid
		if(need_add_bomb && need_add_lotion)begin 
			if(add_bomb_loc == add_lotion_loc) begin //need add_bomb add_lotion at same time and same location->add_bomb first
				if(add_bomb_loc != p1_cor && add_bomb_loc != p2_cor)begin
					if(occ_grid[add_bomb_loc] == OCC_NONE) begin //location must be empty
						occ_grid_nxt[add_bomb_loc] = OCC_ADD_BOMB;
						add_bomb_num_nxt = add_bomb_num + 2'd1;
					end
				end
			end
			else begin //add_bomb_loc != add_lotion_loc 
				if(add_bomb_loc != p1_cor && add_bomb_loc != p2_cor) begin //add_bomb
					if(occ_grid[add_bomb_loc] == OCC_NONE)begin
						occ_grid_nxt[add_bomb_loc] = OCC_ADD_BOMB;
						add_bomb_num_nxt = add_bomb_num + 2'd1;
					end
				end
				if(add_lotion_loc != p1_cor && add_lotion_loc != p2_cor) begin //add_lotion
					if(occ_grid[add_lotion_loc] == OCC_NONE)begin
						occ_grid_nxt[add_lotion_loc] = OCC_LOTION;
						add_lotion_num_nxt = add_lotion_num + 2'd1;
					end
				end
			end
		end
		else if(need_add_bomb || need_add_lotion) begin 
			if(need_add_bomb) begin //add_bomb only
				if(add_bomb_loc != p1_cor && add_bomb_loc != p2_cor) begin
					if(occ_grid[add_bomb_loc] == OCC_NONE) begin
						occ_grid_nxt[add_bomb_loc] = OCC_ADD_BOMB;
						add_bomb_num_nxt = add_bomb_num + 2'd1;
					end
				end
			end
			else begin //add_lotion only
				if(add_lotion_loc != p1_cor && add_lotion_loc != p2_cor) begin
					if(occ_grid[add_lotion_loc] == OCC_NONE) begin
						occ_grid_nxt[add_lotion_loc] = OCC_LOTION;
						add_lotion_num_nxt = add_lotion_num + 2'd1;
					end
				end
			end
		end

	end 

	always_comb begin //for grid states
		//setting bomb and bomb_len
		p1_bomb_unexp_num_next = p1_bomb_unexp_num;
		p2_bomb_unexp_num_next = p2_bomb_unexp_num;
		if(p1_set)begin //player1 set bomb
			p1_bomb_unexp_num_next = p1_bomb_unexp_num + 1; 
		end 
		if(p2_set)begin //player2 set bomb
			p2_bomb_unexp_num_next = p2_bomb_unexp_num + 1;
		end
	end

	Random_B rand_bomb (.change(need_add_bomb), .rst(rst_n), .rand_out(add_bomb_loc));
	Random_L rand_lotion (.change(need_add_lotion), .rst(rst_n), .rand_out(add_lotion_loc));

endmodule






