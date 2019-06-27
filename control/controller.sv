module controller
	(
		input clk, rst, 
		input [2:0] direction_1,	// key pressed
		input [2:0] direction_2,	// key pressed
		input bomb_1,				// whether place bomb
		input bomb_2,				// whether place bomb
		input in_valid_1,
		input in_valid_2,
        // input [255:0] i_grid [0:3]
        input [2:0] i_wall [0:255],
        input [2:0] bomb_max_1,
        input [2:0] bomb_max_2,
        input [2:0] bomb_num_1,
        input [2:0] bomb_num_2,
        input [255:0] bomb_wall_in,
        input i_start,
		// output p1_alive,
        // output p2_alive,
        output p1_set_bomb,
        output p2_set_bomb,
        // output start,
        // output [1:0] p1_power,
        // output [1:0] p2_power, 

        // output [7:0] p1_bomb_position,
        // output [7:0] p2_bomb_position
        output [3:0] p1_x,
        output [3:0] p1_y,
        output [3:0] p2_x,
        output [3:0] p2_y,

        output [7:0] p1_coordinate_o,
        output [7:0] p2_coordinate_o,
		output [1:0] direction_1_o,	// key pressed
		output [1:0] direction_2_o,	// key pressed 

        //for display
        output [3:0] bomb_num_o1,
        output [3:0] bomb_max_1_o,
        output in_valid_1_dis,
        output in_valid_2_dis,
        output [7:0] p1_coordinate_next_o,
        output bomb_valid1_o
	);

    parameter UP 	= 3'd0;
	parameter DOWN 	= 3'd1;
	parameter LEFT 	= 3'd2;
	parameter RIGHT	= 3'd3;
	parameter STOP	= 3'd4;

    logic [2:0] bomb_num_o1_w, bomb_num_o1_r; 
    assign bomb_num_o1 = bomb_num_o1_r;
    assign bomb_max_1_o[2:0] = bomb_max_1_r;
    // logic [2:0] p1_bomb_num_w, p1_bomb_num_r;
    // logic [2:0] p2_bomb_num_w, p2_bomb_num_r;

    logic p1_alive_r, p1_alive_w, p2_alive_r, p2_alive_w;
    logic p1_set_bomb_w, p1_set_bomb_r, p2_set_bomb_w, p2_set_bomb_r;
    logic [1:0] p1_power_w, p1_power_r, p2_power_w, p2_power_r;
    logic [7:0] p1_bomb_position_w, p1_bomb_position_r, p2_bomb_position_w, p2_bomb_position_r;
    logic [3:0] p1_x_w, p1_x_r, p2_x_w, p2_x_r;
    logic [3:0] p1_y_w, p1_y_r, p2_y_w, p2_y_r;
    logic [3:0] p1_x_w5, p1_x_r5, p2_x_w5, p2_x_r5;
    logic [3:0] p1_y_w5, p1_y_r5, p2_y_w5, p2_y_r5;
    logic p1_set_bomb_w5, p1_set_bomb_r5, p2_set_bomb_w5, p2_set_bomb_r5;

    logic [7:0] p1_x_extend, p2_x_extend, p1_y_extend, p2_y_extend;
    logic [8:0] p1_coordinate_next, p2_coordinate_next;
    // logic [8:0] p1_coordinate_next_o, p2_coordinate_next_o;
    assign p1_coordinate_next_o = p1_coordinate_next;

    logic [1:0] face_dir_1_w, face_dir_1_r, face_dir_2_w, face_dir_2_r;
    logic [2:0] bomb_max_1_w, bomb_max_1_r, bomb_max_2_w, bomb_max_2_r;

    // assign p1_alive = p1_alive_r;
    // assign p2_alive = p2_alive_r;
    assign p1_set_bomb = p1_set_bomb_r;
    assign p2_set_bomb = p2_set_bomb_r;
    // assign start = p1_set_bomb_r;
    // assign p1_power = p1_power_r;
    // assign p2_power = p2_power_r;
    // assign p1_bomb_position = p1_bomb_position_r;
    // assign p2_bomb_position = p2_bomb_position_r;
    assign p1_x_extend[3:0] = p1_x_r;
    assign p2_x_extend[3:0] = p2_x_r;
    assign p1_y_extend[3:0] = p1_y_r;
    assign p2_y_extend[3:0] = p2_y_r;
    assign p1_x_extend[7:4] = 4'd0;
    assign p2_x_extend[7:4] = 4'd0;
    assign p1_y_extend[7:4] = 4'd0;
    assign p2_y_extend[7:4] = 4'd0; 
    assign p1_coordinate_o = 8'd16 * p1_y_extend + p1_x_extend;
    assign p2_coordinate_o = 8'd16 * p2_y_extend + p2_x_extend;
    assign p1_x = p1_x_r;
    assign p1_y = p1_y_r;
    assign p2_x = p2_x_r;
    assign p2_y = p2_y_r;

    assign direction_1_o = face_dir_1_r;
    assign direction_2_o = face_dir_2_r;
    logic [7:0] display;
    assign display = (p1_y_extend + 1);
    logic [7:0] display2;
    assign display2 = 8'd16 * display;
    logic [8:0] display3;
    assign display3 = display2 + p1_x_extend;
    // logic [2:0] o_ctr_w, o_ctr_r;
    logic in_valid1_w, in_valid1_r, in_valid2_r, in_valid2_w;
    logic bomb_valid1_w, bomb_valid1_r, bomb_valid2_w, bomb_valid2_r;
    logic [1:0] bomb1_ctr_r, bomb1_ctr_w, bomb2_ctr_r, bomb2_ctr_w;
    logic p1cor_valid_w, p1cor_valid_r, p2cor_valid_r, p2cor_valid_w;

    assign in_valid_1_dis = in_valid1_r;
    assign in_valid_2_dis = in_valid2_r;
    assign bomb_valid1_o = state;

    parameter INIT = 1'b0;
    parameter COMP = 1'b1;
    logic state, next_state;


    always_ff @(posedge clk or posedge rst or posedge i_start) begin
        if(rst || i_start) begin
            // p1_alive_r          <= 1;
            // p2_alive_r          <= 1;
            p1_set_bomb_r       <= 0;
            p2_set_bomb_r       <= 0;
            p1_set_bomb_r5       <= 0;
            p2_set_bomb_r5       <= 0;
            // p1_power_r          <= 1;
            // p2_power_r          <= 1;
            // p1_bomb_position_r  <= 0;
            // p2_bomb_position_r  <= 0;
            p1_x_r              <= 0;
            p1_y_r              <= 0;
            p2_x_r              <= 15;
            p2_y_r              <= 15;
            p1_x_r5             <= 0;
            p1_y_r5             <= 0;
            p2_x_r5             <= 0;
            p2_y_r5             <= 0;

            face_dir_1_r        <= 0;
            face_dir_2_r        <= 0;
            // p1_bomb_num_r       <= 1;
            // p2_bomb_num_r       <= 1;
            bomb_num_o1_r       <= 0;
            bomb_max_1_r        <= 3'd5;
            bomb_max_2_r        <= 0;
            // o_ctr_r             <= 0;
            in_valid1_r         <= 0;
            in_valid2_r         <= 0;
            bomb_valid1_r       <= 1;
            bomb_valid2_r       <= 1;
            //bomb ctr
            bomb1_ctr_r         <= 0;
            bomb2_ctr_r         <= 0;
            p1cor_valid_r       <= 1;
            p2cor_valid_r       <= 1;
            state               <= 0;
		end
		else begin
            // p1_alive_r          <= p1_alive_w;
            // p2_alive_r          <= p2_alive_w;
            p1_set_bomb_r       <= p1_set_bomb_w;
            p2_set_bomb_r       <= p2_set_bomb_w;
            p1_set_bomb_r5      <= p1_set_bomb_w5;
            p2_set_bomb_r5      <= p2_set_bomb_w5;
            // p1_power_r          <= p1_power_w;
            // p2_power_r          <= p2_power_w;
            // p1_bomb_position_r  <= p1_bomb_position_w;
            // p2_bomb_position_r  <= p2_bomb_position_w;
            p1_x_r              <= p1_x_w;
            p1_y_r              <= p1_y_w;
            p2_x_r              <= p2_x_w;
            p2_y_r              <= p2_y_w;
            p1_x_r5             <= p1_x_w5;
            p1_y_r5             <= p1_y_w5;
            p2_x_r5             <= p2_x_w5;
            p2_y_r5             <= p2_y_w5;

            face_dir_1_r        <= face_dir_1_w;
            face_dir_2_r        <= face_dir_2_w;
            // p1_bomb_num_r       <= p1_bomb_num_w;
            // p2_bomb_num_r       <= p2_bomb_num_w;
            bomb_num_o1_r       <= bomb_num_o1_w;
            bomb_max_1_r        <= bomb_max_1_w;
            bomb_max_2_r        <= bomb_max_2_w;
            // o_ctr_r             <= o_ctr_w;
            in_valid1_r         <= in_valid1_w;
            in_valid2_r         <= in_valid2_w;
            bomb_valid1_r       <= bomb_valid1_w;
            bomb_valid2_r       <= bomb_valid2_w;
            bomb1_ctr_r         <= bomb1_ctr_w;
            bomb2_ctr_r         <= bomb2_ctr_w;
            p1cor_valid_r       <= p1cor_valid_w;
            p2cor_valid_r       <= p2cor_valid_w;
            state               <= next_state;
		end 
        
    end 

    // always @* begin
    //     if(o_ctr_r < 3'd5) begin
    //         o_ctr_w = o_ctr_r + 1;
    //     end
    //     else begin
    //         o_ctr_w = 0;
    //     end  
    // end 


    // always @* begin
    //     bomb_max_1_w = bomb_max_1_r;
    //     bomb_max_2_w = bomb_max_2_r;

    //     if(bomb_max_1) begin 
    //         bomb_max_1_w = bomb_max_1_r + 1;
    //     end 
    //     if(bomb_max_2) begin 
    //         bomb_max_2_w = bomb_max_2_r + 1;
    //     end 
    // end 

    always @* begin
        face_dir_1_w = face_dir_1_r;
        face_dir_2_w = face_dir_2_r;

        if(~(direction_1 == STOP)) begin 
            face_dir_1_w = direction_1;
        end 

        if(~(direction_2== STOP)) begin 
            face_dir_2_w = direction_2;
        end
    end 

    // always @* begin 
    //     p1_x_w5         = p1_x_r5;
    //     p2_x_w5         = p2_x_r5;
    //     p1_y_w5         = p1_y_r5;
    //     p2_y_w5         = p2_y_r5;
    //     p1_set_bomb_w5  = 0;
    //     p2_set_bomb_w5  = 0;

    // always @* begin 
    //     p1_x_w5         = p1_x_r5;
    //     p2_x_w5         = p2_x_r5;
    //     p1_y_w5         = p1_y_r5;
    //     p2_y_w5         = p2_y_r5;
    //     p1_set_bomb_w5  = 0;
    //     p2_set_bomb_w5  = 0;

    //     if(o_ctr_r == 3'd3) begin 
    //         p1_x_w5         = p1_x_r;
    //         p2_x_w5         = p2_x_r;
    //         p1_y_w5         = p1_y_r;
    //         p2_y_w5         = p2_y_r;
    //         p1_set_bomb_w5  = p1_set_bomb_r;
    //         p2_set_bomb_w5  = p2_set_bomb_r;
    //     end

    // //     if(o_ctr_r == 3'd2) begin 
    // //         p1_x_w5         = p1_x_r;
    // //         p2_x_w5         = p2_x_r;
    // //         p1_y_w5         = p1_y_r;
    // //         p2_y_w5         = p2_y_r;
    // //         p1_set_bomb_w5  = p1_set_bomb_r;
    // //         p2_set_bomb_w5  = p2_set_bomb_r;
    // //     end

    // end 

    //consider set bomb or not
    //update coordinate
    always @* begin

        p1_set_bomb_w   = 0;
        p2_set_bomb_w   = 0; 

        // p1_set_bomb_w   = p1_set_bomb_r;
        // p2_set_bomb_w   = p2_set_bomb_r;
        // if(o_ctr_r == 3) begin
        //     p1_set_bomb_w = 0;
        //     p2_set_bomb_w = 0;
        // end 

        // p1_bomb_num_w   = p1_bomb_num_r;
        // p2_bomb_num_w   = p2_bomb_num_r;
        p1_x_w          = p1_x_r;
        p2_x_w          = p2_x_r;
        p1_y_w          = p1_y_r;
        p2_y_w          = p2_y_r;
        p1_coordinate_next = 0;
        p2_coordinate_next = 0;
        in_valid1_w = 0;
        in_valid2_w = 0;
        
        //bomb&people valid
        bomb1_ctr_w = bomb1_ctr_r + 1;
        bomb2_ctr_w = bomb2_ctr_r + 1;
        if(bomb1_ctr_r > 2) begin
            bomb1_ctr_w = 0;
        end
        if(bomb2_ctr_r > 2) begin
            bomb1_ctr_w = 0;
        end
        bomb_valid1_w = bomb_valid1_r;
        bomb_valid2_w = bomb_valid2_r;
        p1cor_valid_w = p1cor_valid_r;
        p2cor_valid_w = p2cor_valid_r;

        next_state = state;
        
        // if(state == INIT) begin
        //     p1_coordinate_next = 0;
        //     p2_coordinate_next = 0;
        //     p1_x_w          = 0;
        //     p2_x_w          = 15;
        //     p1_y_w          = 0;
        //     p2_y_w          = 15;
        //     p1_set_bomb_w   = 0;
        //     p2_set_bomb_w   = 0; 
        //     if(i_start) begin
        //         next_state = COMP;
        //     end 
        // end 
    
        if((~bomb_valid1_r) && (bomb1_ctr_r >= 1)) bomb_valid1_w = 1;
        if(~p1cor_valid_r) p1cor_valid_w = 1;
        bomb_num_o1_w = bomb_num_o1_r;
        if(in_valid_1) begin
            // in_valid1_w = 0;
            
            if(bomb_1 & bomb_valid1_r) begin
                //determine if exceed bomb num accessible
                if(bomb_num_1 < bomb_max_1) begin
                    p1_set_bomb_w = 1;
                    bomb_num_o1_w = bomb_num_o1_r + 1;
                    bomb1_ctr_w = 0;
                    bomb_valid1_w = 0;
                end
                // else begin 
                //     bomb_num_o1_w = 0;
                // end 
            end
            
            if((~(direction_1 == STOP)) & p1cor_valid_r) begin
                p1cor_valid_w = 0;
                case(direction_1)
                    UP:
                    begin
                        //determine potential next position
                        if(p1_y_r == 0) begin
                           p1_coordinate_next[8] = 1;
                        end
                        else begin
                            p1_coordinate_next[7:0] = 8'd16 * (p1_y_extend - 1) + p1_x_extend;
                        end
                        //if not wall or the top, y--
                        if(~(i_wall[p1_coordinate_next[7:0]] != 0 || p1_coordinate_next[8] == 1 || bomb_wall_in[p1_coordinate_next[7:0]] == 1)) begin
                            p1_y_w = p1_y_r - 1;
                        end
                    end 
                    DOWN:
                    begin
                        //determine potential next position
                        if(p1_y_r == 4'd15) begin
                           p1_coordinate_next[8] = 1;
                        end
                        else begin
                            p1_coordinate_next = 8'd16 * (p1_y_extend + 1) + p1_x_extend;
                        end
                        //if not wall or the top, y++
                        if(~(i_wall[p1_coordinate_next[7:0]] != 0  || p1_coordinate_next[8] == 1 || bomb_wall_in[p1_coordinate_next[7:0]] == 1)) begin
                            p1_y_w = p1_y_r + 1;
                        end
                    
                    end
                    LEFT:
                    begin
                        //determine potential next position
                        if(p1_x_r == 0) begin
                           p1_coordinate_next[8] = 1;
                        end
                        else begin
                            p1_coordinate_next[7:0] = 8'd16 * (p1_y_extend) + (p1_x_extend-1);
                        end
                        //if not wall or the top, y--
                        if(~(i_wall[p1_coordinate_next[7:0]] != 0  || p1_coordinate_next[8] == 1 || bomb_wall_in[p1_coordinate_next[7:0]] == 1)) begin
                            p1_x_w = p1_x_r - 1;
                        end 

                    end 
                    RIGHT:
                    begin
                        //determine potential next position
                        if(p1_x_r == 4'd15) begin
                           p1_coordinate_next[8] = 1;
                        end
                        else begin
                            p1_coordinate_next[7:0] = 8'd16 * p1_y_extend + (p1_x_extend+1);
                        end
                        //if not wall or the top, y++
                        if(~(i_wall[p1_coordinate_next[7:0]] != 0  || p1_coordinate_next[8] == 1 || bomb_wall_in[p1_coordinate_next[7:0]] == 1)) begin
                            p1_x_w = p1_x_r + 1;
                        end
                    end
                endcase
            end
        end 

        if((~bomb_valid2_r) && (bomb2_ctr_r >= 1)) bomb_valid2_w = 1;
        if(~p2cor_valid_r) p2cor_valid_w = 1;
        if(in_valid_2) begin
            //in_valid2_w = 0;
            
            if(bomb_2 & bomb_valid2_r) begin
                //determine if exceed bomb num accessible
                if(bomb_num_2 < bomb_max_2) begin
                    p2_set_bomb_w = 1;
                    bomb2_ctr_w = 0;
                    bomb_valid2_w = 0;
                end
            end
            
            if((~(direction_2 == STOP)) & p2cor_valid_r) begin
                p2cor_valid_w = 0;
                case(direction_2)
                    UP:
                    begin
                        //determine potential next position
                        if(p2_y_r == 0) begin
                           p2_coordinate_next[8] = 1;
                        end
                        else begin
                            p2_coordinate_next[7:0] = 8'd16 * (p2_y_extend - 1) + p2_x_extend;
                        end
                        //if not wall or the top, y--
                        if(~(i_wall[p2_coordinate_next[7:0]] != 0  || p2_coordinate_next[8] == 1 || bomb_wall_in[p2_coordinate_next[7:0]] == 1)) begin
                            p2_y_w = p2_y_r - 1;
                        end
                    end 
                    DOWN:
                    begin
                        //determine potential next position
                        if(p2_y_r == 4'd15) begin
                           p2_coordinate_next[8] = 1;
                        end
                        else begin
                            p2_coordinate_next[7:0] = 8'd16 * (p2_y_extend + 1) + p2_x_extend;
                        end
                        //if not wall or the top, y++
                        if(~(i_wall[p2_coordinate_next[7:0]] != 0  || p2_coordinate_next[8] == 1 || bomb_wall_in[p2_coordinate_next[7:0]] == 1)) begin
                            p2_y_w = p2_y_r + 1;
                        end
                    
                    end
                    LEFT:
                    begin
                        //determine potential next position
                        if(p2_x_r == 0) begin
                           p2_coordinate_next[8] = 1;
                        end
                        else begin
                            p2_coordinate_next[7:0] = 8'd16 * (p2_y_extend) + (p2_x_extend-1);
                        end
                        //if not wall or the top, y--
                        if(~(i_wall[p2_coordinate_next[7:0]] != 0  || p2_coordinate_next[8] == 1 || bomb_wall_in[p2_coordinate_next[7:0]] == 1)) begin
                            p2_x_w = p2_x_r - 1;
                        end 

                    end 
                    RIGHT:
                    begin
                        //determine potential next position
                        if(p2_x_r == 4'd15) begin
                           p2_coordinate_next[8] = 1;
                        end
                        else begin
                            p2_coordinate_next[7:0] = 8'd16 * p2_y_extend + (p2_x_extend+1);
                        end
                        //if not wall or the top, y++
                        if(~(i_wall[p2_coordinate_next[7:0]] != 0  || p2_coordinate_next[8] == 1 || bomb_wall_in[p2_coordinate_next[7:0]] == 1)) begin
                            p2_x_w = p2_x_r + 1;
                        end
                    end
                endcase
            end 
        end
        

            
        

    end 



endmodule 