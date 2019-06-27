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
                       input        [1:0] gameStatus,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    // player status
    parameter NOT_PLAYER = 2'd0;
    parameter PLAYER_1 = 2'd1;
    parameter PLAYER_2 = 2'd2;

    // game status
    parameter NOT_OVER  = 2'd0;
    parameter GAME_OVER = 2'd1;
    parameter P1_WIN    = 2'd2;
    parameter P2_WIN    = 2'd3; 

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

    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            Red <= 8'haa;
            Green <= 8'hea;
            Blue <= 8'h66;
        end else begin
            Red <= Red_next;
            Green <= Green_next;
            Blue <= Blue_next;
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

        case(gameStatus)
            NOT_OVER: begin
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

                if(DrawX < 80) begin 
                    Red_next = 8'haa;
                    Green_next = 8'hea;
                    Blue_next = 8'h66;
                end

                else if (DrawX > 560) begin 
                    Red_next = 8'haa;
                    Green_next = 8'hea;
                    Blue_next = 8'h66;
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
