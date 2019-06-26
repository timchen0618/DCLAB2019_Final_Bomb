module Wall (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	input [255:0] i_explode,

	//output to display
	output logic [1:0] o_wall_grid [0:255] 
	//output logic [255:0] o_wall
);

parameter EMPTY = 2'd0;
parameter ABLE_WALL = 2'd1;
parameter UNABLE_WALL = 2'd2;

logic [1:0] wall_n [0:255];
logic [255:0] wall_unable_nxt;
// logic [5:0] wall_ctr[0:255];
// logic [5:0] wall_ctr_nxt[0:255];

integer i;
integer index;
//integer idx;

// always_comb begin
// 	for(idx = 0; idx < 255; idx = idx + 1) begin
// 		if(o_wall_grid[idx] == ABLE_WALL) begin
// 			if(i_explode[index] == 1'd1) begin
// 				wall_unable_nxt[index] = 0;
// 			end
// 			else wall_unable_nxt[index] = 1;
// 		end
// 		else wall_unable_nxt[index] = 1;

// 		// if(o_wall_grid[idx] == EMPTY) o_wall[idx] = 0;
// 		// else o_wall[idx] = 1;
// 	end
// end

always_comb begin
	//wall_unable_nxt = o_wall;
	for(index = 0; index <= 255; index = index + 1)begin
		//wall_ctr_nxt[index] = wall_ctr[index];
		if(o_wall_grid[index] == ABLE_WALL) begin
			if(i_explode[index] == 1'd1) begin
				wall_n[index] = EMPTY;
				//wall_unable_nxt[index] = 0;
				// if(wall_ctr[index] >= 6'd30)begin
				// 	wall_n[index] = EMPTY;
				// 	wall_unable_nxt[index] = 0;
				// 	wall_ctr_nxt[index] = 0;
				// end
				// else begin
				// 	wall_n[index] = ABLE_WALL;
				// 	wall_unable_nxt[index] = 1;
				// 	wall_ctr_nxt[index] = wall_ctr[index] + 6'd1;
				// end
			end
			else begin
				wall_n[index] = o_wall_grid[index];
				//wall_unable_nxt[index] = 1;
			end	
		end
		else begin
			wall_n[index] = o_wall_grid[index];
		end
	end
end

always_ff @(posedge clk or posedge rst) begin 
	if(rst) begin
			//o_wall

			//with add bomb inside
			o_wall_grid[4] <= ABLE_WALL;
			o_wall_grid[11] <= ABLE_WALL;
			o_wall_grid[18] <= ABLE_WALL;
			o_wall_grid[29] <= ABLE_WALL;
			o_wall_grid[32] <= ABLE_WALL;
			o_wall_grid[47] <= ABLE_WALL;
			o_wall_grid[208] <= ABLE_WALL;
			o_wall_grid[226] <= ABLE_WALL;
			o_wall_grid[244] <= ABLE_WALL;
			o_wall_grid[223] <= ABLE_WALL;
			o_wall_grid[237] <= ABLE_WALL;
			o_wall_grid[251] <= ABLE_WALL;
			o_wall_grid[8] <= ABLE_WALL;
			o_wall_grid[9] <= ABLE_WALL;
			o_wall_grid[40] <= ABLE_WALL;
			o_wall_grid[41] <= ABLE_WALL;
			o_wall_grid[70] <= ABLE_WALL;
			o_wall_grid[71] <= ABLE_WALL;
			o_wall_grid[102] <= ABLE_WALL;
			o_wall_grid[103] <= ABLE_WALL;
			o_wall_grid[136] <= ABLE_WALL;
			o_wall_grid[137] <= ABLE_WALL;
			o_wall_grid[168] <= ABLE_WALL;
			o_wall_grid[169] <= ABLE_WALL;
			o_wall_grid[198] <= ABLE_WALL;
			o_wall_grid[199] <= ABLE_WALL;
			o_wall_grid[230] <= ABLE_WALL;
			o_wall_grid[231] <= ABLE_WALL;

			//with lotion inside
			o_wall_grid[19] <= ABLE_WALL ;
			o_wall_grid[28] <= ABLE_WALL ;
			o_wall_grid[33] <= ABLE_WALL ;
			o_wall_grid[46] <= ABLE_WALL ;
			o_wall_grid[80] <= ABLE_WALL ;
			o_wall_grid[81] <= ABLE_WALL ;
			o_wall_grid[174] <= ABLE_WALL ;
			o_wall_grid[175] <= ABLE_WALL ;
			o_wall_grid[209] <= ABLE_WALL ;
			o_wall_grid[222] <= ABLE_WALL ;
			o_wall_grid[227] <= ABLE_WALL ;
			o_wall_grid[236] <= ABLE_WALL ;

			//unable wall
			o_wall_grid[34] <= UNABLE_WALL;
			o_wall_grid[35] <= UNABLE_WALL;
			o_wall_grid[50] <= UNABLE_WALL;
			o_wall_grid[51] <= UNABLE_WALL;
			o_wall_grid[44] <= UNABLE_WALL;
			o_wall_grid[45] <= UNABLE_WALL;
			o_wall_grid[60] <= UNABLE_WALL;
			o_wall_grid[61] <= UNABLE_WALL;
			o_wall_grid[194] <= UNABLE_WALL;
			o_wall_grid[195] <= UNABLE_WALL;
			o_wall_grid[204] <= UNABLE_WALL;
			o_wall_grid[205] <= UNABLE_WALL;
			o_wall_grid[210] <= UNABLE_WALL;
			o_wall_grid[211] <= UNABLE_WALL;
			o_wall_grid[220] <= UNABLE_WALL;
			o_wall_grid[221] <= UNABLE_WALL;

			//able wall with nothin inside
			o_wall_grid[5] <= ABLE_WALL ;
			o_wall_grid[10] <= ABLE_WALL ;
			o_wall_grid[20] <= ABLE_WALL ;
			o_wall_grid[21] <= ABLE_WALL ;
			o_wall_grid[24] <= ABLE_WALL ;
			o_wall_grid[25] <= ABLE_WALL ;
			o_wall_grid[26] <= ABLE_WALL ;
			o_wall_grid[27] <= ABLE_WALL ;
			o_wall_grid[36] <= ABLE_WALL ;
			o_wall_grid[37] <= ABLE_WALL ;
			o_wall_grid[42] <= ABLE_WALL ;
			o_wall_grid[43] <= ABLE_WALL ;
			o_wall_grid[48] <= ABLE_WALL ;
			o_wall_grid[49] <= ABLE_WALL ;
			o_wall_grid[52] <= ABLE_WALL ;
			o_wall_grid[53] <= ABLE_WALL ;
			o_wall_grid[56] <= ABLE_WALL ;
			o_wall_grid[57] <= ABLE_WALL ;
			o_wall_grid[58] <= ABLE_WALL ;
			o_wall_grid[59] <= ABLE_WALL ;
			o_wall_grid[62] <= ABLE_WALL ;
			o_wall_grid[63] <= ABLE_WALL ;
			o_wall_grid[64] <= ABLE_WALL ;
			o_wall_grid[65] <= ABLE_WALL ;
			o_wall_grid[66] <= ABLE_WALL ;
			o_wall_grid[67] <= ABLE_WALL ;
			o_wall_grid[68] <= ABLE_WALL ;
			o_wall_grid[69] <= ABLE_WALL ;
			o_wall_grid[74] <= ABLE_WALL ;
			o_wall_grid[75] <= ABLE_WALL ;
			o_wall_grid[76] <= ABLE_WALL ;
			o_wall_grid[77] <= ABLE_WALL ;
			o_wall_grid[78] <= ABLE_WALL ;
			o_wall_grid[79] <= ABLE_WALL ;
			o_wall_grid[82] <= ABLE_WALL ;
			o_wall_grid[83] <= ABLE_WALL ;
			o_wall_grid[84] <= ABLE_WALL ;
			o_wall_grid[85] <= ABLE_WALL ;
			o_wall_grid[86] <= ABLE_WALL ;
			o_wall_grid[87] <= ABLE_WALL ;
			o_wall_grid[90] <= ABLE_WALL ;
			o_wall_grid[91] <= ABLE_WALL ;
			o_wall_grid[92] <= ABLE_WALL ;
			o_wall_grid[93] <= ABLE_WALL ;
			o_wall_grid[94] <= ABLE_WALL ;
			o_wall_grid[95] <= ABLE_WALL ;
			o_wall_grid[96] <= ABLE_WALL ;
			o_wall_grid[97] <= ABLE_WALL ;
			o_wall_grid[98] <= ABLE_WALL ;
			o_wall_grid[99] <= ABLE_WALL ;
			o_wall_grid[100] <= ABLE_WALL ;
			o_wall_grid[101] <= ABLE_WALL ;
			o_wall_grid[106] <= ABLE_WALL ;
			o_wall_grid[107] <= ABLE_WALL ;
			o_wall_grid[108] <= ABLE_WALL ;
			o_wall_grid[109] <= ABLE_WALL ;
			o_wall_grid[110] <= ABLE_WALL ;
			o_wall_grid[111] <= ABLE_WALL ;
			o_wall_grid[112] <= ABLE_WALL ;
			o_wall_grid[113] <= ABLE_WALL ;
			o_wall_grid[114] <= ABLE_WALL ;
			o_wall_grid[115] <= ABLE_WALL ;
			o_wall_grid[116] <= ABLE_WALL ;
			o_wall_grid[117] <= ABLE_WALL ;
			o_wall_grid[118] <= ABLE_WALL ;
			o_wall_grid[119] <= ABLE_WALL ;
			o_wall_grid[122] <= ABLE_WALL ;
			o_wall_grid[123] <= ABLE_WALL ;
			o_wall_grid[124] <= ABLE_WALL ;
			o_wall_grid[125] <= ABLE_WALL ;
			o_wall_grid[126] <= ABLE_WALL ;
			o_wall_grid[127] <= ABLE_WALL ;
			o_wall_grid[128] <= ABLE_WALL ;
			o_wall_grid[129] <= ABLE_WALL ;
			o_wall_grid[130] <= ABLE_WALL ;
			o_wall_grid[131] <= ABLE_WALL ;
			o_wall_grid[132] <= ABLE_WALL ;
			o_wall_grid[133] <= ABLE_WALL ;
			o_wall_grid[138] <= ABLE_WALL ;
			o_wall_grid[139] <= ABLE_WALL ;
			o_wall_grid[140] <= ABLE_WALL ;
			o_wall_grid[141] <= ABLE_WALL ;
			o_wall_grid[142] <= ABLE_WALL ;
			o_wall_grid[143] <= ABLE_WALL ;
			o_wall_grid[144] <= ABLE_WALL ;
			o_wall_grid[145] <= ABLE_WALL ;
			o_wall_grid[146] <= ABLE_WALL ;
			o_wall_grid[147] <= ABLE_WALL ;
			o_wall_grid[148] <= ABLE_WALL ;
			o_wall_grid[149] <= ABLE_WALL ;
			o_wall_grid[152] <= ABLE_WALL ;
			o_wall_grid[153] <= ABLE_WALL ;
			o_wall_grid[154] <= ABLE_WALL ;
			o_wall_grid[155] <= ABLE_WALL ;
			o_wall_grid[156] <= ABLE_WALL ;
			o_wall_grid[157] <= ABLE_WALL ;
			o_wall_grid[158] <= ABLE_WALL ;
			o_wall_grid[159] <= ABLE_WALL ;
			o_wall_grid[160] <= ABLE_WALL ;
			o_wall_grid[161] <= ABLE_WALL ;
			o_wall_grid[162] <= ABLE_WALL ;
			o_wall_grid[163] <= ABLE_WALL ;
			o_wall_grid[164] <= ABLE_WALL ;
			o_wall_grid[165] <= ABLE_WALL ;
			o_wall_grid[170] <= ABLE_WALL ;
			o_wall_grid[171] <= ABLE_WALL ;
			o_wall_grid[172] <= ABLE_WALL ;
			o_wall_grid[173] <= ABLE_WALL ;
			o_wall_grid[176] <= ABLE_WALL ;
			o_wall_grid[177] <= ABLE_WALL ;
			o_wall_grid[178] <= ABLE_WALL ;
			o_wall_grid[179] <= ABLE_WALL ;
			o_wall_grid[180] <= ABLE_WALL ;
			o_wall_grid[181] <= ABLE_WALL ;
			o_wall_grid[184] <= ABLE_WALL ;
			o_wall_grid[185] <= ABLE_WALL ;
			o_wall_grid[186] <= ABLE_WALL ;
			o_wall_grid[187] <= ABLE_WALL ;
			o_wall_grid[188] <= ABLE_WALL ;
			o_wall_grid[189] <= ABLE_WALL ;
			o_wall_grid[190] <= ABLE_WALL ;
			o_wall_grid[191] <= ABLE_WALL ;
			o_wall_grid[192] <= ABLE_WALL ;
			o_wall_grid[193] <= ABLE_WALL ;
			o_wall_grid[196] <= ABLE_WALL ;
			o_wall_grid[197] <= ABLE_WALL ;
			o_wall_grid[202] <= ABLE_WALL ;
			o_wall_grid[203] <= ABLE_WALL ;
			o_wall_grid[206] <= ABLE_WALL ;
			o_wall_grid[207] <= ABLE_WALL ;
			o_wall_grid[212] <= ABLE_WALL ;
			o_wall_grid[213] <= ABLE_WALL ;
			o_wall_grid[214] <= ABLE_WALL ;
			o_wall_grid[215] <= ABLE_WALL ;
			o_wall_grid[218] <= ABLE_WALL ;
			o_wall_grid[219] <= ABLE_WALL ;
			o_wall_grid[228] <= ABLE_WALL ;
			o_wall_grid[229] <= ABLE_WALL ;
			o_wall_grid[234] <= ABLE_WALL ;
			o_wall_grid[235] <= ABLE_WALL ;
			o_wall_grid[245] <= ABLE_WALL ;
			o_wall_grid[246] <= ABLE_WALL ;
			o_wall_grid[247] <= ABLE_WALL ;
			o_wall_grid[250] <= ABLE_WALL ;

			//empty
			o_wall_grid[0] <= EMPTY;
			o_wall_grid[1] <= EMPTY;
			o_wall_grid[2] <= EMPTY;
			o_wall_grid[3] <= EMPTY;
			o_wall_grid[6] <= EMPTY;
			o_wall_grid[7] <= EMPTY;
			o_wall_grid[12] <= EMPTY;
			o_wall_grid[13] <= EMPTY;
			o_wall_grid[14] <= EMPTY;
			o_wall_grid[15] <= EMPTY;
			o_wall_grid[16] <= EMPTY;
			o_wall_grid[17] <= EMPTY;
			o_wall_grid[22] <= EMPTY;
			o_wall_grid[23] <= EMPTY;
			o_wall_grid[30] <= EMPTY;
			o_wall_grid[31] <= EMPTY;
			o_wall_grid[38] <= EMPTY;
			o_wall_grid[39] <= EMPTY;
			o_wall_grid[54] <= EMPTY;
			o_wall_grid[55] <= EMPTY;
			o_wall_grid[72] <= EMPTY;
			o_wall_grid[73] <= EMPTY;
			o_wall_grid[88] <= EMPTY;
			o_wall_grid[89] <= EMPTY;
			o_wall_grid[104] <= EMPTY;
			o_wall_grid[105] <= EMPTY;
			o_wall_grid[120] <= EMPTY;
			o_wall_grid[121] <= EMPTY;
			o_wall_grid[134] <= EMPTY;
			o_wall_grid[135] <= EMPTY;
			o_wall_grid[150] <= EMPTY;
			o_wall_grid[151] <= EMPTY;
			o_wall_grid[166] <= EMPTY;
			o_wall_grid[167] <= EMPTY;
			o_wall_grid[182] <= EMPTY;
			o_wall_grid[183] <= EMPTY;
			o_wall_grid[200] <= EMPTY;
			o_wall_grid[201] <= EMPTY;
			o_wall_grid[216] <= EMPTY;
			o_wall_grid[217] <= EMPTY;
			o_wall_grid[224] <= EMPTY;
			o_wall_grid[225] <= EMPTY;
			o_wall_grid[232] <= EMPTY;
			o_wall_grid[233] <= EMPTY;
			o_wall_grid[238] <= EMPTY;
			o_wall_grid[239] <= EMPTY;
			o_wall_grid[240] <= EMPTY;
			o_wall_grid[241] <= EMPTY;
			o_wall_grid[242] <= EMPTY;
			o_wall_grid[243] <= EMPTY;
			o_wall_grid[248] <= EMPTY;
			o_wall_grid[249] <= EMPTY;
			o_wall_grid[252] <= EMPTY;
			o_wall_grid[253] <= EMPTY;
			o_wall_grid[254] <= EMPTY;
			o_wall_grid[255] <= EMPTY;
	end 
	else begin
		for(i = 0; i < 256; i = i+1)begin
			o_wall_grid[i] <= wall_n[i];
		end
		//o_wall <= wall_unable_nxt;
	end
end

endmodule