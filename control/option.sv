module option(
    input clk, rst, 
    input [2:0] direction_1,	// key pressed
	input [2:0] direction_2,	// key pressed
    input in_valid_1,
	input in_valid_2,
    input i_start,
    output [1:0] opt_ctr,
    output select
);

    parameter UP 	= 3'd0;
	parameter DOWN 	= 3'd1;
	parameter LEFT 	= 3'd2;
	parameter RIGHT	= 3'd3;
	parameter STOP	= 3'd4;
    parameter BBB   = 3'd5;

    parameter COMP = 2'd1;
    parameter IDLE = 2'd2;
    parameter INIT = 2'd0;
    parameter COUNT = 2'd3;

    logic in_valid1_w, in_valid1_r, in_valid2_w, in_valid2_r;
    logic [1:0] opt_ctr_w, opt_ctr_r;
    logic select_w, select_r;
    logic idle_w, idle_r;
    logic [1:0] state, next_state;
    logic [4:0] in_ctr_w, in_ctr_r;
    assign opt_ctr = opt_ctr_r;
    assign select = select_r;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            in_valid1_r <= 1;
            in_valid2_r <= 1; 
            opt_ctr_r   <= 0;
            select_r    <= 0;
            idle_r      <= 0;
            state       <= 0;
            in_ctr_r    <= 0;
        end
        else begin
            in_valid1_r <= in_valid1_w;
            in_valid2_r <= in_valid2_w;
            opt_ctr_r   <= opt_ctr_w;
            select_r    <= select_w;
            idle_r      <= idle_w;
            state       <= next_state;
            in_ctr_r    <= in_ctr_w;
        end
    end 

    always_comb begin
        in_valid1_w = in_valid1_r;
        in_valid2_w = in_valid2_r;
        opt_ctr_w   = opt_ctr_r;
        select_w    = select_r;
        idle_w      = idle_r;
        next_state  = state;
        in_ctr_w    = in_ctr_r;

        case(state)
            INIT: begin 
                if(i_start) begin
                    next_state = COUNT;
                    in_ctr_w = 0;
                end 
            end 
            COUNT: begin
                if(in_ctr_r == 5'd15) begin
                    if(idle_r) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = COMP;
                    end
                    in_ctr_w = 0;
                end
                else begin
                    in_ctr_w = in_ctr_r + 1;
                end
            end
            IDLE: begin
                opt_ctr_w = opt_ctr_r;
                in_valid1_w = 0;
                in_valid2_w = 0;
                select_w = 1;
            end
            COMP: begin
                if(~in_valid1_r) begin
                    in_valid1_w = 1;
                end
                if(~in_valid2_r) begin
                    in_valid2_w = 1;
                end
                if(in_valid_1 & in_valid1_r) begin
                    if(direction_1 == DOWN) begin
                        in_valid1_w = 0;
                        if(opt_ctr_r < 3) begin
                            opt_ctr_w = opt_ctr_r + 1;
                        end
                    end
                    if(direction_1 == UP) begin
                        in_valid1_w = 0;
                        if(opt_ctr_r > 0) begin
                            opt_ctr_w = opt_ctr_r - 1;
                        end
                    end
                    if(direction_1 == BBB) begin
                        in_valid1_w = 0;
                        idle_w = 1;
                        next_state = COUNT;
                        in_ctr_w = 0;
                    end
                end 
                if(in_valid_2 & in_valid2_r) begin
                    if(direction_2 == DOWN) begin
                        in_valid2_w = 0;
                        if(opt_ctr_r < 3) begin
                            opt_ctr_w = opt_ctr_r + 1;
                        end
                    end
                    if(direction_2 == UP) begin
                        in_valid2_w = 0;
                        if(opt_ctr_r > 0) begin
                            opt_ctr_w = opt_ctr_r - 1;
                        end
                    end
                    // if(direction_2 == STOP) begin
                    //     in_valid2_w = 0;
                    //     idle_w = 1;
                    //     next_state = COUNT;
                    //     in_ctr_w = 0;
                    // end
                end
                
            end

        endcase

        
    end

endmodule