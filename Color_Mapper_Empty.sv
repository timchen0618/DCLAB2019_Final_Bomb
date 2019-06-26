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
module  color_mapper ( 
                       input        [9:0] DrawX, DrawY,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

 //    assign tileX = (DrawX - 80) / 30;
 //    assign tileY = DrawY / 30; 
 //    assign state = StateArray [tileX + tileY*16];

	// backgroundROM Background(
	// 	.state(state),
	// 	.read_address(DrawX - 80 - 30*tileX + (DrawY -30*tileY)*30),
	// 	.data_Out(color_out)
	// );


    always_comb begin
        Red = 8'h00;
        Green = 8'hf0;
        Blue = 8'hf0;

    // 	if(DrawX < 80) begin 
    // 		Red = 8'ha9;
 			// Green = 8'h15;
 			// Blue = 8'hf0;
    // 	end

    // 	else if (DrawX > 560) begin 
    // 		Red = 8'h72;
 			// Green = 8'hc8;
 			// Blue = 8'h2f;
    // 	end

    // 	else begin
    // 		case (color_out)
    // 			0: begin 
    // 				Red = 8'ha9;
 			// 		Green = 8'h15;
 			// 		Blue = 8'hf0;
    // 			end
    // 			1: begin 
    // 				Red = 8'h72;
 			// 		Green = 8'hc8;
 			// 		Blue = 8'h2f;
    // 			end
    // 			2: begin 
    // 				Red = 8'h3C;
 			// 		Green = 8'hAB;
 			// 		Blue = 8'hDD;
    // 			end
    // 			3: begin 
    // 				Red = 8'h93;
 			// 		Green = 8'hCF;
 			// 		Blue = 8'h81;
    // 			end
    // 			4: begin 
    // 				Red = 8'h98;
 			// 		Green = 8'hE7;
 			// 		Blue = 8'hD8;
    // 			end
    // 			5: begin 
    // 				Red = 8'h37;
 			// 		Green = 8'hE2;
 			// 		Blue = 8'hD5;
    // 			end
    // 			6: begin 
    // 				Red = 8'h22;
 			// 		Green = 8'hBB;
 			// 		Blue = 8'hE6;
    // 			end
    // 			7: begin 
    // 				Red = 8'hfc;
 			// 		Green = 8'hc6;
 			// 		Blue = 8'h56;
    // 			end
    // 			8: begin 
    // 				Red = 8'ha8;
 			// 		Green = 8'h7C;
 			// 		Blue = 8'h07;
    // 			end
    // 			9: begin 
    // 				Red = 8'hcb;
 			// 		Green = 8'h8C;
 			// 		Blue = 8'h1A;
    // 			end
    // 			10: begin 
    // 				Red = 8'hE7;
 			// 		Green = 8'h89;
 			// 		Blue = 8'h24;
    // 			end
    // 			11: begin 
    // 				Red = 8'hf2;
 			// 		Green = 8'hAB;
 			// 		Blue = 8'h45;
    // 			end
    // 			12: begin 
    // 				Red = 8'ha0;
 			// 		Green = 8'h61;
 			// 		Blue = 8'h1f;
    // 			end
    // 			13: begin 
    // 				Red = 8'h09;
 			// 		Green = 8'h64;
 			// 		Blue = 8'hc8;
    // 			end
    // 			14: begin 
    // 				Red = 8'hfb;
 			// 		Green = 8'hfe;
 			// 		Blue = 8'hf2;
    // 			end
    // 			15: begin 
    // 				Red = 8'h39;
 			// 		Green = 8'h40;
 			// 		Blue = 8'h3a;
    // 			end
    // 		endcase // color_out
    // 	end
    end
// '0xa915f0', '0x72c82f', '0x3CABDD', '0x93CF81', '0x98E7D8', '0x37E2D5', '0x22BBE6', '0xFCC656', '0xA87C07', '0xCB8C1A', '0xE78924', '0xF2AB45', '0xA0611F', '0x0964c8', '0xfbfef2', '0x39403a'

endmodule
