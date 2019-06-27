module ps2_controller
	(
		input clk, rst, 
		input [7:0] rx_data,       // data received
		input rx_done_tick,        // ps2 receive done tick
		output rx_success,
		output [2:0] direction_1,	// key pressed
		output [2:0] direction_2,	// key pressed
		output bomb_1,				// whether place bomb
		output bomb_2,				// whether place bomb
		output out_valid_1,
		output out_valid_2,
		output [3:0] out1,
		output [3:0] out2, 
		output [3:0] out3, 
		output [3:0] out4,
		output start,
		output [2:0] state_o,
		input begin_
		
	);

	parameter UP 	= 3'd0;
	parameter DOWN 	= 3'd1;
	parameter LEFT 	= 3'd2;
	parameter RIGHT	= 3'd3;
	parameter STOP	= 3'd4;
	parameter BBB   = 3'd5;

	parameter IDLE = 2'b00;
	parameter OUT  = 2'b01;
	parameter INIT = 2'b10;
	parameter CNT  = 2'b11;

	logic out_valid_1_r, out_valid_1_w;
	logic out_valid_2_r, out_valid_2_w;
	logic bomb_1_r, bomb_1_w;
	logic bomb_2_r, bomb_2_w;
	logic [1:0] state, next_state;
	logic [7:0] prev_key_r, prev_key_w;
	logic [7:0] rx_data_r, rx_data_w;
	logic rx_done_w, rx_done_r;
	logic [2:0] direction_1_r, direction_1_w, direction_2_r, direction_2_w;
	logic rx_success_w, rx_success_r;
	assign state_o[1:0] = state;
	assign state_o[2] = 0;
	
	//for display rx_data
	logic [3:0] out1_w, out1_r, out2_w, out2_r, out3_w, out3_r, out4_w, out4_r;
	logic [4:0] o_ctr_w, o_ctr_r;
	logic start_w, start_r;
	assign out1 = out1_r;
	assign out2 = out2_r;
	assign out3 = out3_r;
	assign out4 = out4_r;

	assign direction_1 = direction_1_r;
	assign direction_2 = direction_2_r;
	assign bomb_1 = bomb_1_r;
	assign bomb_2 = bomb_2_r;
	assign out_valid_1 = out_valid_1_r;
	assign out_valid_2 = out_valid_2_r;
	assign rx_success = rx_success_r;
	assign start = start_r;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
				out_valid_1_r 	<= 0;
				out_valid_2_r 	<= 0;
				direction_1_r 	<= 4;
				bomb_1_r		<= 0;
				direction_2_r 	<= 4;
				bomb_2_r		<= 0;
				state 			<= INIT;
				prev_key_r		<= 0;
				rx_data_r 		<= 0;
				rx_done_r 		<= 0;
				rx_success_r 	<= 0;
				//for display rx_data
				out1_r			<= 0;
				out2_r			<= 0;
				out3_r			<= 0;
				out4_r			<= 0;
				o_ctr_r			<= 0;
				start_r 		<= 0;
		end
		else begin
				out_valid_1_r 	<= out_valid_1_w;
				out_valid_2_r 	<= out_valid_2_w;
				direction_1_r 	<= direction_1_w;
				bomb_1_r		<= bomb_1_w;
				direction_2_r 	<= direction_2_w;
				bomb_2_r		<= bomb_2_w;
				state 			<= next_state;
				prev_key_r		<= prev_key_w;
				rx_data_r 		<= rx_data_w;
				rx_done_r 		<= rx_done_w;
				rx_success_r 	<= rx_success_w;
				//for display rx_data
				out1_r 			<= out1_w;
				out2_r 			<= out2_w;
				out3_r			<= out3_w;
				out4_r 			<= out4_w;
				o_ctr_r			<= o_ctr_w;
				start_r 		<= start_w;
		end 
	end 

	// always @* begin
	// 	//for display rx_data
	// 	out1_w 			= out1_r;
	// 	out2_w 			= out2_r;
	// 	out3_w			= out3_r;
	// 	out4_w 			= out4_r;
	// 	o_ctr_w			= o_ctr_r;

	// 	if(rx_done_r) begin
	// 		o_ctr_w = o_ctr_r + 1;
	// 		case(o_ctr_r)
	// 			0: begin
	// 				out1_w = rx_data_r[3:0];
	// 			end
	// 			1: begin
	// 				out2_w = rx_data_r[3:0];
	// 			end
	// 			2: begin
	// 				out3_w = rx_data_r[3:0];
	// 			end
	// 			3: begin
	// 				out4_w = rx_data_r[3:0];
	// 			end
	// 		endcase
	// 	end 


	// end

	always @* begin
		out_valid_1_w 	= 0;
		out_valid_2_w 	= 0;
		direction_1_w 	= direction_1_r;
		bomb_1_w 		= 0;
		direction_2_w 	= direction_2_r;
		bomb_2_w 		= 0;
		next_state 		= state;
		prev_key_w 		= prev_key_r;
		rx_data_w		= 0;
		rx_done_w 		= 0;
		rx_success_w 	= 0;
		start_w 		= start_r;
		o_ctr_w 		= o_ctr_r;

		if(start_r == 1) begin 
			start_w = 0;
		end 
		case(state)
			INIT: begin
				if(rx_done_tick) begin
					rx_done_w = 1;
				end 
				if(rx_done_r) begin
					next_state = IDLE;
					start_w = 1;
				end
			end 
			CNT: begin
				if(o_ctr_r == 8) begin
					next_state = IDLE;
					o_ctr_w = 0;
				end 
				else begin
					o_ctr_w = o_ctr_r + 1;
				end 
			end 
			IDLE:
			begin
				start_w = 0;
				if(rx_done_tick) begin
					prev_key_w = rx_data;
					if(prev_key_r == 8'hF0) begin
						next_state = IDLE;
						out_valid_1_w = 0;
						out_valid_2_w = 0;
						rx_done_w = 0;
					end
					else begin
						rx_data_w = rx_data;
						rx_done_w = 1;
						next_state = OUT;
						out_valid_1_w = 0;
						out_valid_2_w = 0;
					end 
				end 
				if(begin_) begin
					next_state = CNT;
					o_ctr_w = 0;
				end 
			end 

			OUT:
			begin
				if(begin_) begin
					next_state = CNT;
					o_ctr_w = 0;
				end 
				if(rx_done_tick &(~rx_success_r)) begin
					rx_done_w = 1;
					rx_data_w = rx_data;
				end
				else begin
					rx_done_w = 0;
					rx_data_w = 0;
				end 
				if(rx_done_r) begin
					prev_key_w = rx_data_r;
					
					if(prev_key_r == 8'hF0) begin
						next_state = IDLE;
						out_valid_1_w = 0;
						out_valid_2_w = 0;
						prev_key_w = 8'hF0;
					end
					else begin 
						case(rx_data_r)
							8'hF0:
							begin
								next_state 	  = IDLE;
								out_valid_1_w = 0;
								out_valid_2_w = 0;
							end 
							8'h1D: 
							begin 
								direction_1_w = UP;
								bomb_1_w 	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w = 1;
							end
							8'h1B: 
							begin
								direction_1_w = DOWN;
								bomb_1_w 	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w  = 1;
							end 
							8'h1C: 
							begin 
								direction_1_w = LEFT;
								bomb_1_w 	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w  = 1;
							end 
							8'h23: 
							begin
								direction_1_w = RIGHT;
								bomb_1_w	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w  = 1;
							end 
							8'h29:
							begin 
								direction_1_w = STOP;
								bomb_1_w 	  = 1;
								next_state 	  = OUT;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w  = 1;
							end 
							8'h75: 
							begin 
								direction_2_w = UP;
								bomb_2_w      = 0;
								next_state 	  = OUT;
								out_valid_1_w = 0;
								out_valid_2_w = 1;
								rx_success_w  = 1;
							end
							8'h72: 
							begin
								direction_2_w = DOWN;
								bomb_2_w 	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 0;
								out_valid_2_w = 1;
								rx_success_w  = 1;
							end 
							8'h6B: 
							begin 
								direction_2_w = LEFT;
								bomb_2_w 	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 0;
								out_valid_2_w = 1;
								rx_success_w  = 1;
							end 
							8'h74: 
							begin
								direction_2_w = RIGHT;
								bomb_2_w	  = 0;
								next_state 	  = OUT;
								out_valid_1_w = 0;
								out_valid_2_w = 1;
								rx_success_w  = 1;
							end 
							8'h5A:
							begin 
								direction_2_w = STOP;
								bomb_2_w 	  = 1;
								next_state 	  = OUT;
								out_valid_1_w = 0;
								out_valid_2_w = 1;
								rx_success_w  = 1;
							end 
							8'h32:
							begin
								direction_1_w = BBB;
								out_valid_1_w = 1;
								out_valid_2_w = 0;
								rx_success_w  = 1;
							end 
						endcase // rx_data
					end 
				end 


			end
		endcase

	end 


endmodule // ps2_controller