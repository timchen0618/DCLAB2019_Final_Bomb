//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input        clk,
                       input        rst,
                       input        [3:0] p1_tile_x,
                       input        [3:0] p1_tile_y,
                       input        [3:0] p2_tile_x,
                       input        [3:0] p2_tile_y,
                       input 		[3:0] StateArray [0:255] ,
                       input        [9:0] DrawX, DrawY,
                       input        [2:0] gameStatus,
                       input        [2:0] o_p1_cap, o_p2_cap,
                       input        [1:0] o_p1_len, o_p2_len,
                       input        [1:0] option_ctr,
                       input        Begin_i,
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
                       output logic Beginnnn_o
                     );

    
    // player status
    parameter NOT_PLAYER = 2'd0;
    parameter PLAYER_1 = 2'd1;
    parameter PLAYER_2 = 2'd2;

    // game status
    parameter STARTING  = 3'd0;
    parameter OPTION    = 3'd1;
    parameter NOT_OVER  = 3'd2;
    parameter GAME_OVER = 3'd3;
    parameter P1_WIN    = 3'd4;
    parameter P2_WIN    = 3'd5;

    // OCC
    parameter OCC_NONE      = 5'd0;
    parameter OCC_LOTION    = 5'd1; // sth that can add bomb length
    parameter OCC_BOMB      = 5'd2; // unxploded bomb
    parameter OCC_ADD_BOMB  = 5'd3; // thing that can add bomb capacity
    parameter OCC_CEN       = 5'd4;  // the center of the explosion 
    parameter OCC_UP        = 5'd5;  
    parameter OCC_DOWN      = 5'd6;  
    parameter OCC_LEFT      = 5'd7;
    parameter OCC_RIGHT     = 5'd8;
    parameter OCC_WALL_ABLE = 5'd9;
    parameter OCC_WALL_UN   = 5'd10;

    logic [7:0] Red, Green, Blue;
    logic [7:0] Red_next, Green_next, Blue_next;
    logic [3:0] tileX, tileY;
    logic [4:0] state;
    logic [3:0] color_out;

    logic [1:0] player_status;
    logic [3:0] player_color_out;

    logic player;

    logic [3:0] gameover_color_out;
    logic [3:0] p1_win_color_out;
    logic [3:0] p2_win_color_out;
    logic [3:0] backgroundPic_color_out;
    logic [3:0] p1_icon_color_out, p2_icon_color_out;
    logic [3:0] number1_color_out, number2_color_out, number3_color_out, number4_color_out;
    logic [3:0] addbomb1_color_out, addbomb2_color_out, lotion1_color_out, lotion2_color_out;
    logic [3:0] start_color_out;
    logic [3:0] title_color_out, option0_color_out, option1_color_out, option2_color_out, option3_color_out;

    // BEGINNNNNN
    logic Beginnnn_nxt;
    logic [3:0] Begin_ctr, Begin_ctr_nxt;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

    assign tileX = (DrawX - 80) / 30;
    assign tileY = DrawY / 30; 
    assign state = StateArray [tileX + tileY*16];

    playerROM playerROM(
        .clk(clk),
        .player(player),
        .read_address(DrawX - 80 - 30*tileX + (DrawY -30*tileY)*30),
        .data_Out(player_color_out)
    );

	backgroundROM Background(
        .clk(clk),
		.state(state),
		.read_address(DrawX - 80 - 30*tileX + (DrawY -30*tileY)*30),
		.data_Out(color_out)
	);

    backgroundPicROM BackgroundPic(
        .clk(clk),
        .read_address(DrawX/2 + 320*(DrawY/2)),
        .data_Out(backgroundPic_color_out)
    );

    gameoverROM gameoverROM(
        .clk(clk),
        .read_address(DrawX/2 + 320*(DrawY/2)),
        .data_Out(gameover_color_out)
    );

    p1_winROM p1_winROM(
        .clk(clk),
        .read_address(DrawX/2 + 320*(DrawY/2)),
        .data_Out(p1_win_color_out)
    );

    p2_winROM p2_winROM(
        .clk(clk),
        .read_address(DrawX/2 + 320*(DrawY/2)),
        .data_Out(p2_win_color_out)
    );

    // for right and left DISPLAY
    numberROM  numberROM_1(     // ADD_BOMB_LEFT   // size = 30*120
        .clk(clk),
        .state(o_p1_cap-1),
        .read_address(DrawX -25 + (DrawY - 130)*30),  // (25, 130)
        .data_Out(number1_color_out)
    );
    numberROM  numberROM_2(     // LOTION_LEFT   // size = 30*120
        .clk(clk),
        .state(o_p1_len),
        .read_address(DrawX -25 + (DrawY - 300)*30),
        .data_Out(number2_color_out)
    );
    numberROM  numberROM_3(     // ADD_BOMB_RIGHT    // size = 30*120
        .clk(clk),
        .state(o_p2_cap-1),
        .read_address(DrawX -585 + (DrawY - 130)*30),
        .data_Out(number3_color_out)
    );
    numberROM  numberROM_4(    // LOTION_RIGHT     // size = 30*120
        .clk(clk),
        .state(o_p2_len),
        .read_address(DrawX -585 + (DrawY - 300)*30),
        .data_Out(number4_color_out)
    );

    p1_iconROM p1_iconROM(  // (10, 10)   // size = 60*60
        .clk(clk),
        .read_address(DrawX -10 + (DrawY - 10)*60),
        .data_Out(p1_icon_color_out)
    );

    p2_iconROM p2_iconROM(
        .clk(clk),
        .read_address(DrawX -570 + (DrawY - 10)*60),
        .data_Out(p2_icon_color_out)
    );

    backgroundROM addBomb1(   
        .clk(clk),
        .state(OCC_ADD_BOMB),
        .read_address(DrawX -25 + (DrawY - 90)*30),
        .data_Out(addbomb1_color_out)
    );

    backgroundROM addBomb2(
        .clk(clk),
        .state(OCC_ADD_BOMB),
        .read_address(DrawX -585 + (DrawY - 90)*30),
        .data_Out(addbomb2_color_out)
    );

    backgroundROM lotion1(
        .clk(clk),
        .state(OCC_LOTION),
        .read_address(DrawX -25 + (DrawY - 260)*30),
        .data_Out(lotion1_color_out)
    );
    backgroundROM lotion2(
        .clk(clk),
        .state(OCC_LOTION),
        .read_address(DrawX -585 + (DrawY - 260)*30),
        .data_Out(lotion2_color_out)
    );

    startROM startROM(
        .clk(clk),
        .read_address(DrawX/2 + 320*(DrawY/2)),
        .data_Out(start_color_out)
    );



    // OPTION
    titleROM titleROM(
        .clk(clk),
        .read_address(DrawX - 160 + (DrawY - 50)*320),
        .data_Out(title_color_out)
    );

    optionROM  option0(  // 160*60
        .clk(clk),
        .option(2'd0),
        .option_ctr(option_ctr),
        .read_address(DrawX - 240 + (DrawY - 125)*160),
        .data_Out(option0_color_out)
    );

    optionROM  option1(
        .clk(clk),
        .option(2'd1),
        .option_ctr(option_ctr),
        .read_address(DrawX - 240 + (DrawY - 205)*160),
        .data_Out(option1_color_out)
    );

    optionROM  option2(
        .clk(clk),
        .option(2'd2),
        .option_ctr(option_ctr),
        .read_address(DrawX - 240 + (DrawY - 285)*160),
        .data_Out(option2_color_out)
    );

    optionROM  option3(
        .clk(clk),
        .option(2'd3),
        .option_ctr(option_ctr),
        .read_address(DrawX - 240 + (DrawY - 365)*160),
        .data_Out(option3_color_out)
    );

    

    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            Red         <= 8'haa;
            Green       <= 8'hea;
            Blue        <= 8'h66;
            Beginnnn_o  <= 0;
            Begin_ctr   <= 0;
        end else begin
            Red         <= Red_next;
            Green       <= Green_next;
            Blue        <= Blue_next;
            Beginnnn_o  <= Beginnnn_nxt;
            Begin_ctr   <= Begin_ctr_nxt;
        end
    end

    always_comb begin 
        Beginnnn_nxt = 0;
        Begin_ctr_nxt = Begin_ctr;
        if(gameStatus == OPTION && Begin_i ) Beginnnn_nxt = 1;
        if(Beginnnn_o == 1) begin 
            if(Begin_ctr == 4'd15) begin 
                Begin_ctr_nxt = 0;
                Beginnnn_nxt = 0;
            end
            else begin 
                Begin_ctr_nxt =  Begin_ctr + 1;
                Beginnnn_nxt = 1;
            end
        end
    end

    always_comb begin
        if(tileX == p1_tile_x && tileY == p1_tile_y) player_status = PLAYER_1;
        else if(tileX == p2_tile_x && tileY == p2_tile_y) player_status = PLAYER_2;
        else player_status = NOT_PLAYER;

        if(player_status == PLAYER_1)  begin
            player = 0;
        end
        else if(player_status == PLAYER_2) begin
            player = 1;
        end
        else begin 
            player = 0;
        end
        
        // LOAD BACKGROUND FIRST
        case (backgroundPic_color_out)
            0: begin 
                Red_next = 8'haa;
                Green_next = 8'hea;
                Blue_next = 8'h66;
            end
            1: begin 
                Red_next = 8'haa;
                Green_next = 8'hea;
                Blue_next = 8'h66;
            end
            2: begin 
                Red_next = 8'h3C;
                Green_next = 8'hAB;
                Blue_next = 8'hDD;
            end
            3: begin 
                Red_next = 8'h93;
                Green_next = 8'hCF;
                Blue_next = 8'h81;
            end
            4: begin 
                Red_next = 8'h98;
                Green_next = 8'hE7;
                Blue_next = 8'hD8;
            end
            5: begin 
                Red_next = 8'h37;
                Green_next = 8'hE2;
                Blue_next = 8'hD5;
            end
            6: begin 
                Red_next = 8'h22;
                Green_next = 8'hBB;
                Blue_next = 8'hE6;
            end
            7: begin 
                Red_next = 8'hfc;
                Green_next = 8'hc6;
                Blue_next = 8'h56;
            end
            8: begin 
                Red_next = 8'ha8;
                Green_next = 8'h7C;
                Blue_next = 8'h07;
            end
            9: begin 
                Red_next = 8'hcb;
                Green_next = 8'h8C;
                Blue_next = 8'h1A;
            end
            10: begin 
                Red_next = 8'hE7;
                Green_next = 8'h89;
                Blue_next = 8'h24;
            end
            11: begin 
                Red_next = 8'hf2;
                Green_next = 8'hAB;
                Blue_next = 8'h45;
            end
            12: begin 
                Red_next = 8'ha0;
                Green_next = 8'h61;
                Blue_next = 8'h1f;
            end
            13: begin 
                Red_next = 8'h09;
                Green_next = 8'h64;
                Blue_next = 8'hc8;
            end
            14: begin 
                Red_next = 8'hfb;
                Green_next = 8'hfe;
                Blue_next = 8'hf2;
            end
            15: begin 
                Red_next = 8'h39;
                Green_next = 8'h40;
                Blue_next = 8'h3a;
            end
        endcase // backgroundpic_color_out

        case(gameStatus)

            STARTING: begin 
                case (start_color_out)
                    0: begin 
                        Red_next = 8'hc7;
                        Green_next = 8'h06;
                        Blue_next = 8'h00;
                    end
                    1: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    2: begin 
                        Red_next = 8'h3C;
                        Green_next = 8'hAB;
                        Blue_next = 8'hDD;
                    end
                    3: begin 
                        Red_next = 8'h93;
                        Green_next = 8'hCF;
                        Blue_next = 8'h81;
                    end
                    4: begin 
                        Red_next = 8'h98;
                        Green_next = 8'hE7;
                        Blue_next = 8'hD8;
                    end
                    5: begin 
                        Red_next = 8'h37;
                        Green_next = 8'hE2;
                        Blue_next = 8'hD5;
                    end
                    6: begin 
                        Red_next = 8'h22;
                        Green_next = 8'hBB;
                        Blue_next = 8'hE6;
                    end
                    7: begin 
                        Red_next = 8'hfc;
                        Green_next = 8'hc6;
                        Blue_next = 8'h56;
                    end
                    8: begin 
                        Red_next = 8'ha8;
                        Green_next = 8'h7C;
                        Blue_next = 8'h07;
                    end
                    9: begin 
                        Red_next = 8'hcb;
                        Green_next = 8'h8C;
                        Blue_next = 8'h1A;
                    end
                    10: begin 
                        Red_next = 8'hE7;
                        Green_next = 8'h89;
                        Blue_next = 8'h24;
                    end
                    11: begin 
                        Red_next = 8'hf2;
                        Green_next = 8'hAB;
                        Blue_next = 8'h45;
                    end
                    12: begin 
                        Red_next = 8'ha0;
                        Green_next = 8'h61;
                        Blue_next = 8'h1f;
                    end
                    13: begin 
                        Red_next = 8'h09;
                        Green_next = 8'h64;
                        Blue_next = 8'hc8;
                    end
                    14: begin 
                        Red_next = 8'hfb;
                        Green_next = 8'hfe;
                        Blue_next = 8'hf2;
                    end
                    15: begin 
                        Red_next = 8'h39;
                        Green_next = 8'h40;
                        Blue_next = 8'h3a;
                    end
                endcase // start_color_out
            end

            OPTION: begin 
                if(DrawY > 50 && DrawY < 95) begin 
                    if(DrawX > 160 && DrawX < 480) begin 
                        case (title_color_out)
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // gameover_color_out
                    end
                end
                else if(DrawY > 125 && DrawY < 185) begin 
                    if(DrawX > 240 && DrawX < 400) begin 
                        case (option0_color_out)
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // gameover_color_out
                    end
                end
                else if(DrawY > 205 && DrawY < 265) begin 
                    if(DrawX > 240 && DrawX < 400) begin 
                        case (option1_color_out)
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // gameover_color_out
                    end
                end
                else if(DrawY > 285 && DrawY < 345) begin 
                    if(DrawX > 240 && DrawX < 400) begin 
                        case (option2_color_out)
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // gameover_color_out
                    end
                end
                else if(DrawY > 365 && DrawY < 425) begin 
                    if(DrawX > 240 && DrawX < 400) begin 
                        case (option3_color_out)
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // gameover_color_out
                    end
                end
            end

            NOT_OVER: begin
                // BACKGROUND
                if(tileX % 2 == 1 ) begin
                    if(tileY % 2 == 1) begin
                        Red_next = 8'h32;
                        Green_next = 8'h96;
                        Blue_next = 8'h5a;
                    end
                    else begin
                        Red_next = 8'h50;
                        Green_next = 8'hd2;
                        Blue_next = 8'h78;
                    end
                end
                else begin 
                    if(tileY % 2 == 0) begin
                        Red_next = 8'h32;
                        Green_next = 8'h96;
                        Blue_next = 8'h5a;
                    end
                    else begin
                        Red_next = 8'h50;
                        Green_next = 8'hd2;
                        Blue_next = 8'h78;
                    end
                end
                // #32965a    #50d278

                if(DrawX < 80 || DrawX > 560) begin 
                    // fbfef2
                    Red_next = 8'hfb;
                    Green_next = 8'hfe;
                    Blue_next = 8'hf2;
                end
                if(DrawX < 80) begin 
                    if(DrawY > 10 && DrawY < 70) begin 
                        if(DrawX > 10 && DrawX < 70) begin 
                            case (p1_icon_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 90 && DrawY < 120) begin 
                        if(DrawX > 25 && DrawX < 55) begin 
                            case (addbomb1_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 130 && DrawY < 250) begin 
                        if(DrawX > 25 && DrawX < 55) begin 
                            case (number1_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase
                        end
                    end
                    else if(DrawY > 260 && DrawY < 290) begin 
                        if(DrawX > 25 && DrawX < 55) begin 
                            case (lotion1_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 300 && DrawY < 420) begin 
                        if(DrawX > 25 && DrawX < 55) begin 
                            case (number2_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase
                        end
                    end
                end

                else if (DrawX > 560) begin 
                    if(DrawY > 10 && DrawY < 70) begin 
                        if(DrawX > 570 && DrawX < 630) begin 
                            case (p2_icon_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 90 && DrawY < 120) begin 
                        if(DrawX > 585 && DrawX < 615) begin 
                            case (addbomb2_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 130 && DrawY < 250) begin 
                        if(DrawX > 585 && DrawX < 615) begin 
                            case (number3_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase
                        end
                    end
                    else if(DrawY > 260 && DrawY < 290) begin 
                        if(DrawX > 585 && DrawX < 615) begin 
                            case (lotion2_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase // color_out
                        end
                    end
                    else if(DrawY > 300 && DrawY < 420) begin 
                        if(DrawX > 585 && DrawX < 615) begin 
                            case (number4_color_out)
                                2: begin 
                                    Red_next = 8'h3C;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'hDD;
                                end
                                3: begin 
                                    Red_next = 8'h93;
                                    Green_next = 8'hCF;
                                    Blue_next = 8'h81;
                                end
                                4: begin 
                                    Red_next = 8'h98;
                                    Green_next = 8'hE7;
                                    Blue_next = 8'hD8;
                                end
                                5: begin 
                                    Red_next = 8'h37;
                                    Green_next = 8'hE2;
                                    Blue_next = 8'hD5;
                                end
                                6: begin 
                                    Red_next = 8'h22;
                                    Green_next = 8'hBB;
                                    Blue_next = 8'hE6;
                                end
                                7: begin 
                                    Red_next = 8'hfc;
                                    Green_next = 8'hc6;
                                    Blue_next = 8'h56;
                                end
                                8: begin 
                                    Red_next = 8'ha8;
                                    Green_next = 8'h7C;
                                    Blue_next = 8'h07;
                                end
                                9: begin 
                                    Red_next = 8'hcb;
                                    Green_next = 8'h8C;
                                    Blue_next = 8'h1A;
                                end
                                10: begin 
                                    Red_next = 8'hE7;
                                    Green_next = 8'h89;
                                    Blue_next = 8'h24;
                                end
                                11: begin 
                                    Red_next = 8'hf2;
                                    Green_next = 8'hAB;
                                    Blue_next = 8'h45;
                                end
                                12: begin 
                                    Red_next = 8'ha0;
                                    Green_next = 8'h61;
                                    Blue_next = 8'h1f;
                                end
                                13: begin 
                                    Red_next = 8'h09;
                                    Green_next = 8'h64;
                                    Blue_next = 8'hc8;
                                end
                                14: begin 
                                    Red_next = 8'hfb;
                                    Green_next = 8'hfe;
                                    Blue_next = 8'hf2;
                                end
                                15: begin 
                                    Red_next = 8'h39;
                                    Green_next = 8'h40;
                                    Blue_next = 8'h3a;
                                end
                            endcase
                        end
                    end
                end          

                else begin
                    if(player_status == PLAYER_1 || player_status == PLAYER_2) begin
                        case (player_color_out)
                            // 0: begin 
                            //     Red_next = 8'haa;
                            //     Green_next = 8'hea;
                            //     Blue_next = 8'h66;
                            // end
                            // 1: begin 
                            //     Red_next = 8'haa;
                            //     Green_next = 8'hea;
                            //     Blue_next = 8'h66;
                            // end
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // color_out
                    end

                    else begin
                        case (color_out)
                            // 0: begin 
                            //     Red_next = 8'haa;
                            //     Green_next = 8'hea;
                            //     Blue_next = 8'h66;
                            // end
                            // 1: begin 
                            //     Red_next = 8'haa;
                            //     Green_next = 8'hea;
                            //     Blue_next = 8'h66;
                            // end
                            2: begin 
                                Red_next = 8'h3C;
                                Green_next = 8'hAB;
                                Blue_next = 8'hDD;
                            end
                            3: begin 
                                Red_next = 8'h93;
                                Green_next = 8'hCF;
                                Blue_next = 8'h81;
                            end
                            4: begin 
                                Red_next = 8'h98;
                                Green_next = 8'hE7;
                                Blue_next = 8'hD8;
                            end
                            5: begin 
                                Red_next = 8'h37;
                                Green_next = 8'hE2;
                                Blue_next = 8'hD5;
                            end
                            6: begin 
                                Red_next = 8'h22;
                                Green_next = 8'hBB;
                                Blue_next = 8'hE6;
                            end
                            7: begin 
                                Red_next = 8'hfc;
                                Green_next = 8'hc6;
                                Blue_next = 8'h56;
                            end
                            8: begin 
                                Red_next = 8'ha8;
                                Green_next = 8'h7C;
                                Blue_next = 8'h07;
                            end
                            9: begin 
                                Red_next = 8'hcb;
                                Green_next = 8'h8C;
                                Blue_next = 8'h1A;
                            end
                            10: begin 
                                Red_next = 8'hE7;
                                Green_next = 8'h89;
                                Blue_next = 8'h24;
                            end
                            11: begin 
                                Red_next = 8'hf2;
                                Green_next = 8'hAB;
                                Blue_next = 8'h45;
                            end
                            12: begin 
                                Red_next = 8'ha0;
                                Green_next = 8'h61;
                                Blue_next = 8'h1f;
                            end
                            13: begin 
                                Red_next = 8'h09;
                                Green_next = 8'h64;
                                Blue_next = 8'hc8;
                            end
                            14: begin 
                                Red_next = 8'hfb;
                                Green_next = 8'hfe;
                                Blue_next = 8'hf2;
                            end
                            15: begin 
                                Red_next = 8'h39;
                                Green_next = 8'h40;
                                Blue_next = 8'h3a;
                            end
                        endcase // color_out
                    end
                end
            end
            GAME_OVER: begin 
                case (gameover_color_out)
                    0: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    1: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    2: begin 
                        Red_next = 8'h3C;
                        Green_next = 8'hAB;
                        Blue_next = 8'hDD;
                    end
                    3: begin 
                        Red_next = 8'h93;
                        Green_next = 8'hCF;
                        Blue_next = 8'h81;
                    end
                    4: begin 
                        Red_next = 8'h98;
                        Green_next = 8'hE7;
                        Blue_next = 8'hD8;
                    end
                    5: begin 
                        Red_next = 8'h37;
                        Green_next = 8'hE2;
                        Blue_next = 8'hD5;
                    end
                    6: begin 
                        Red_next = 8'h22;
                        Green_next = 8'hBB;
                        Blue_next = 8'hE6;
                    end
                    7: begin 
                        Red_next = 8'hfc;
                        Green_next = 8'hc6;
                        Blue_next = 8'h56;
                    end
                    8: begin 
                        Red_next = 8'ha8;
                        Green_next = 8'h7C;
                        Blue_next = 8'h07;
                    end
                    9: begin 
                        Red_next = 8'hcb;
                        Green_next = 8'h8C;
                        Blue_next = 8'h1A;
                    end
                    10: begin 
                        Red_next = 8'hE7;
                        Green_next = 8'h89;
                        Blue_next = 8'h24;
                    end
                    11: begin 
                        Red_next = 8'hf2;
                        Green_next = 8'hAB;
                        Blue_next = 8'h45;
                    end
                    12: begin 
                        Red_next = 8'ha0;
                        Green_next = 8'h61;
                        Blue_next = 8'h1f;
                    end
                    13: begin 
                        Red_next = 8'h09;
                        Green_next = 8'h64;
                        Blue_next = 8'hc8;
                    end
                    14: begin 
                        Red_next = 8'hfb;
                        Green_next = 8'hfe;
                        Blue_next = 8'hf2;
                    end
                    15: begin 
                        Red_next = 8'h39;
                        Green_next = 8'h40;
                        Blue_next = 8'h3a;
                    end
                endcase // gameover_color_out
            end

            P1_WIN: begin 
                case (p1_win_color_out)
                    0: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    1: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    2: begin 
                        Red_next = 8'h3C;
                        Green_next = 8'hAB;
                        Blue_next = 8'hDD;
                    end
                    3: begin 
                        Red_next = 8'h93;
                        Green_next = 8'hCF;
                        Blue_next = 8'h81;
                    end
                    4: begin 
                        Red_next = 8'h98;
                        Green_next = 8'hE7;
                        Blue_next = 8'hD8;
                    end
                    5: begin 
                        Red_next = 8'h37;
                        Green_next = 8'hE2;
                        Blue_next = 8'hD5;
                    end
                    6: begin 
                        Red_next = 8'h22;
                        Green_next = 8'hBB;
                        Blue_next = 8'hE6;
                    end
                    7: begin 
                        Red_next = 8'hfc;
                        Green_next = 8'hc6;
                        Blue_next = 8'h56;
                    end
                    8: begin 
                        Red_next = 8'ha8;
                        Green_next = 8'h7C;
                        Blue_next = 8'h07;
                    end
                    9: begin 
                        Red_next = 8'hcb;
                        Green_next = 8'h8C;
                        Blue_next = 8'h1A;
                    end
                    10: begin 
                        Red_next = 8'hE7;
                        Green_next = 8'h89;
                        Blue_next = 8'h24;
                    end
                    11: begin 
                        Red_next = 8'hf2;
                        Green_next = 8'hAB;
                        Blue_next = 8'h45;
                    end
                    12: begin 
                        Red_next = 8'ha0;
                        Green_next = 8'h61;
                        Blue_next = 8'h1f;
                    end
                    13: begin 
                        Red_next = 8'h09;
                        Green_next = 8'h64;
                        Blue_next = 8'hc8;
                    end
                    14: begin 
                        Red_next = 8'hfb;
                        Green_next = 8'hfe;
                        Blue_next = 8'hf2;
                    end
                    15: begin 
                        Red_next = 8'h39;
                        Green_next = 8'h40;
                        Blue_next = 8'h3a;
                    end
                endcase // p1_win_color_out
            end

            P2_WIN: begin 
                case (p2_win_color_out)
                    0: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    1: begin 
                        Red_next = 8'haa;
                        Green_next = 8'hea;
                        Blue_next = 8'h66;
                    end
                    2: begin 
                        Red_next = 8'h3C;
                        Green_next = 8'hAB;
                        Blue_next = 8'hDD;
                    end
                    3: begin 
                        Red_next = 8'h93;
                        Green_next = 8'hCF;
                        Blue_next = 8'h81;
                    end
                    4: begin 
                        Red_next = 8'h98;
                        Green_next = 8'hE7;
                        Blue_next = 8'hD8;
                    end
                    5: begin 
                        Red_next = 8'h37;
                        Green_next = 8'hE2;
                        Blue_next = 8'hD5;
                    end
                    6: begin 
                        Red_next = 8'h22;
                        Green_next = 8'hBB;
                        Blue_next = 8'hE6;
                    end
                    7: begin 
                        Red_next = 8'hfc;
                        Green_next = 8'hc6;
                        Blue_next = 8'h56;
                    end
                    8: begin 
                        Red_next = 8'ha8;
                        Green_next = 8'h7C;
                        Blue_next = 8'h07;
                    end
                    9: begin 
                        Red_next = 8'hcb;
                        Green_next = 8'h8C;
                        Blue_next = 8'h1A;
                    end
                    10: begin 
                        Red_next = 8'hE7;
                        Green_next = 8'h89;
                        Blue_next = 8'h24;
                    end
                    11: begin 
                        Red_next = 8'hf2;
                        Green_next = 8'hAB;
                        Blue_next = 8'h45;
                    end
                    12: begin 
                        Red_next = 8'ha0;
                        Green_next = 8'h61;
                        Blue_next = 8'h1f;
                    end
                    13: begin 
                        Red_next = 8'h09;
                        Green_next = 8'h64;
                        Blue_next = 8'hc8;
                    end
                    14: begin 
                        Red_next = 8'hfb;
                        Green_next = 8'hfe;
                        Blue_next = 8'hf2;
                    end
                    15: begin 
                        Red_next = 8'h39;
                        Green_next = 8'h40;
                        Blue_next = 8'h3a;
                    end
                endcase // p2_win_color_out
            end

        endcase    
    end
// '0xa915f0', '0x72c82f', '0x3CABDD', '0x93CF81', '0x98E7D8', '0x37E2D5', '0x22BBE6', '0xFCC656', '0xA87C07', '0xCB8C1A', '0xE78924', '0xF2AB45', '0xA0611F', '0x0964c8', '0xfbfef2', '0x39403a'

endmodule
