module Gadget(
	//input
	input clk,
	input start,
	input rst,
	input [1:0] gadget_type,
	input [7:0] p1_cor,
	input [7:0] p2_cor,
	input [255:0] i_explode,

	//output to keyboard control
	output logic [2:0] o_p1_cap, //bomb number
	output logic [2:0] o_p2_cap,

	//output to BOMB control
	output logic [1:0] o_p1_len, //bomb len
	output logic [1:0] o_p2_len,

	//output to display
	output logic [2:0] gadget_grid[0:255],

	//output for debug
	output p2_able_to_add_bomb

	);
	//gadget type
	parameter DC_5 = 2'd1;
	parameter ORIGINAL = 2'd0;
	parameter EE = 2'd2;
	parameter LOVE_DCLAB = 2'd3;

	//gadget states
	parameter EMPTY = 3'd0;
	parameter LOTION = 3'd1;
	parameter ADD_BOMB = 3'd2;
	parameter HIDE_LOTION = 3'd3;
	parameter HIDE_ADD_BOMB =3'd4;

	//parameter for max bomb num and bomb len
	parameter MAX_BOMB_NUM = 3'd4; //add_bomb
	parameter MAX_LEN = 2'd3; //lotion

	//output logic next
	logic [2:0] gadget_n [0:255]; 
	logic [2:0] p1_cap_nxt;
	logic [2:0] p2_cap_nxt;
	logic [1:0] p1_len_nxt;
	logic [1:0] p2_len_nxt;

	logic [5:0] gadget_ctr [0:255];
	logic [5:0] gadget_ctr_nxt [0:255];
	//wire boolean and assign
	logic p1_able_to_add_bomb;
	//logic p2_able_to_add_bomb;
	logic p1_able_to_add_len;
	logic p2_able_to_add_len;

	assign p1_able_to_add_bomb = (o_p1_cap == MAX_BOMB_NUM) ? 1'd0: 1'd1;
	assign p2_able_to_add_bomb = (o_p2_cap == MAX_BOMB_NUM) ? 1'd0: 1'd1;
	assign p1_able_to_add_len = (o_p1_len == MAX_LEN) ? 1'd0: 1'd1;
	assign p2_able_to_add_len = (o_p2_len == MAX_LEN) ? 1'd0: 1'd1;

	integer i,ii,iii,idx,index;
	//input logic 
	always_comb begin
		p1_len_nxt = o_p1_len;
		p2_len_nxt = o_p2_len;
		p1_cap_nxt = o_p1_cap;
		p2_cap_nxt = o_p2_cap;

		if(gadget_grid[p1_cor] == LOTION)begin
			if(p1_able_to_add_len == 1'd1) begin
				p1_len_nxt  = o_p1_len + 2'd1;
			end
			else p1_len_nxt = 2'd3;
		end

		if(gadget_grid[p2_cor] == LOTION)begin
			if(p1_cor != p2_cor) begin
				if(p2_able_to_add_len == 1'd1) begin
					p2_len_nxt  = o_p2_len + 2'd1;
				end
				else p2_len_nxt = 2'd3;
			end
			
		end	

		if(gadget_grid[p1_cor] == ADD_BOMB)begin
			if(p1_able_to_add_bomb == 1'd1)begin
				p1_cap_nxt = o_p1_cap + 2'd1;
			end
			else p1_cap_nxt = 3'd4;
		end
		
		if(gadget_grid[p2_cor] == ADD_BOMB)begin
			if(p1_cor != p2_cor)begin
				if(p2_able_to_add_bomb == 1'd1)begin
					p2_cap_nxt = o_p2_cap + 2'd1;
				end
				else p2_cap_nxt = 3'd4;
			end
		end
	end

	always_comb begin
		for(idx = 0; idx < 256; idx = idx +1) begin
			gadget_n[idx] = gadget_grid[idx];
			gadget_ctr_nxt[idx] = gadget_ctr[idx];
			
			case(gadget_grid[idx]) 
				EMPTY:
				begin
					gadget_n[idx] = gadget_grid[idx];
				end
				LOTION:
				begin
					if(i_explode[idx] == 1'd1)begin
						gadget_n[idx] = EMPTY;
						//p1_len_nxt = 2'd1;
					end
					else begin
						//p1_len_nxt = 2'd3;
						if(idx == p1_cor || idx == p2_cor) begin
							gadget_n[idx] = EMPTY;
						end
						else begin
							gadget_n[idx] = gadget_grid[idx];
						end
					end
				end
				ADD_BOMB:
				begin
					if(i_explode[idx] == 1'd1)begin
						gadget_n[idx] = EMPTY;
					end
					else begin
						if(idx == p1_cor || idx == p2_cor)begin
							gadget_n[idx] = EMPTY;
						end
						else begin
							gadget_n[idx] = gadget_grid[idx];
						end
					end
				end
				HIDE_LOTION:
				begin
					if(i_explode[idx] == 1'd1)begin
						if(gadget_ctr[idx] >= 6'd17) begin
							gadget_n[idx] = LOTION;
							gadget_ctr_nxt[idx] = 0;
						end
						else begin
							gadget_ctr_nxt[idx] = gadget_ctr[idx] + 1;
							gadget_n[idx] = gadget_grid[idx];
						end
					end
					else begin
						gadget_n[idx] = gadget_grid[idx];
					end
				end
				HIDE_ADD_BOMB:
				begin
					if(i_explode[idx] == 1'd1) begin
						if(gadget_ctr[idx] >= 6'd17) begin
							gadget_n[idx] = ADD_BOMB;
							gadget_ctr_nxt[idx] = 0;
						end
						else begin
							gadget_ctr_nxt[idx] = gadget_ctr[idx] + 1;
							gadget_n[idx] = gadget_grid[idx];
						end

					end
					else begin
						gadget_n[idx] = gadget_grid[idx];
					end
				end
				default:
				begin
					gadget_n[idx] = gadget_grid[idx];
					// p1_cap_nxt = o_p1_cap;
					// p2_cap_nxt = o_p2_cap;
					// p1_len_nxt = o_p1_len;
					// p2_len_nxt = o_p2_len;
				end
			endcase
		end
	end 

	always_ff @(posedge clk or posedge start or posedge rst) begin 
		if(rst) begin
			for(i = 0; i< 256; i = i+1)begin
				gadget_ctr[i] <= 0;
				gadget_grid[i] <= EMPTY;
			end
			o_p1_cap <= 3'd1;
			o_p2_cap <= 3'd1;
			o_p1_len <= 2'd0;
			o_p2_len <= 2'd0;
		end
		else if(start) begin
			//grid state counter
			for(index = 0; index < 256; index = index + 1)begin
				gadget_ctr[index] 	<=	0;
			end

			//output logic
			o_p1_cap <= 3'd1;
			o_p2_cap <= 3'd1;
			o_p1_len <= 2'd0;
			o_p2_len <= 2'd0;
			//initial grid background
			//EMPTY
			case(gadget_type)
				DC_5:
				begin
					for(ii = 0 ; ii < 256; ii = ii+1) begin
						gadget_grid[ii] <= EMPTY;
					end

					gadget_grid[18] <= HIDE_ADD_BOMB;
					gadget_grid[28] <= HIDE_ADD_BOMB;
					gadget_grid[53] <= HIDE_ADD_BOMB;
					gadget_grid[58] <= HIDE_ADD_BOMB;
					gadget_grid[66] <= HIDE_ADD_BOMB;
					gadget_grid[92] <= HIDE_ADD_BOMB;
					gadget_grid[136] <= HIDE_ADD_BOMB;
					gadget_grid[145] <= HIDE_ADD_BOMB;
					gadget_grid[147] <= HIDE_ADD_BOMB;
					gadget_grid[150] <= HIDE_ADD_BOMB;
					gadget_grid[167] <= HIDE_ADD_BOMB;
					gadget_grid[172] <= HIDE_ADD_BOMB;
					gadget_grid[174] <= HIDE_ADD_BOMB;
					gadget_grid[201] <= HIDE_ADD_BOMB;
					gadget_grid[210] <= HIDE_ADD_BOMB;
					gadget_grid[221] <= HIDE_ADD_BOMB;

					gadget_grid[34] <= HIDE_LOTION;
					gadget_grid[50] <= HIDE_LOTION;
					gadget_grid[74] <= HIDE_LOTION;
					gadget_grid[91] <= HIDE_LOTION;
					gadget_grid[178] <= HIDE_LOTION;
					gadget_grid[189] <= HIDE_LOTION;
					gadget_grid[194] <= HIDE_LOTION;
					gadget_grid[198] <= HIDE_LOTION;
					gadget_grid[199] <= HIDE_LOTION;
					gadget_grid[205] <= HIDE_LOTION;
				end
				ORIGINAL:
				begin
					//gadget grid
					gadget_grid[0] <= EMPTY;
					gadget_grid[1] <= EMPTY;
					gadget_grid[2] <= EMPTY;
					gadget_grid[3] <= EMPTY;
					gadget_grid[6] <= EMPTY;
					gadget_grid[7] <= EMPTY;
					gadget_grid[12] <= EMPTY;
					gadget_grid[13] <= EMPTY;
					gadget_grid[14] <= EMPTY;
					gadget_grid[15] <= EMPTY;
					gadget_grid[16] <= EMPTY;
					gadget_grid[17] <= EMPTY;
					gadget_grid[22] <= EMPTY;
					gadget_grid[23] <= EMPTY;
					gadget_grid[30] <= EMPTY;
					gadget_grid[31] <= EMPTY;
					gadget_grid[38] <= EMPTY;
					gadget_grid[39] <= EMPTY;
					gadget_grid[54] <= EMPTY;
					gadget_grid[55] <= EMPTY;
					gadget_grid[72] <= EMPTY;
					gadget_grid[73] <= EMPTY;
					gadget_grid[88] <= EMPTY;
					gadget_grid[89] <= EMPTY;
					gadget_grid[104] <= EMPTY;
					gadget_grid[105] <= EMPTY;
					gadget_grid[120] <= EMPTY;
					gadget_grid[121] <= EMPTY;
					gadget_grid[134] <= EMPTY;
					gadget_grid[135] <= EMPTY;
					gadget_grid[150] <= EMPTY;
					gadget_grid[151] <= EMPTY;
					gadget_grid[166] <= EMPTY;
					gadget_grid[167] <= EMPTY;
					gadget_grid[182] <= EMPTY;
					gadget_grid[183] <= EMPTY;
					gadget_grid[200] <= EMPTY;
					gadget_grid[201] <= EMPTY;
					gadget_grid[216] <= EMPTY;
					gadget_grid[217] <= EMPTY;
					gadget_grid[224] <= EMPTY;
					gadget_grid[225] <= EMPTY;
					gadget_grid[232] <= EMPTY;
					gadget_grid[233] <= EMPTY;
					gadget_grid[238] <= EMPTY;
					gadget_grid[239] <= EMPTY;
					gadget_grid[240] <= EMPTY;
					gadget_grid[241] <= EMPTY;
					gadget_grid[242] <= EMPTY;
					gadget_grid[243] <= EMPTY;
					gadget_grid[248] <= EMPTY;
					gadget_grid[249] <= EMPTY;
					gadget_grid[252] <= EMPTY;
					gadget_grid[253] <= EMPTY;
					gadget_grid[254] <= EMPTY;
					gadget_grid[255] <= EMPTY;
					
					//UNABLE WALL: STILL display EMPTY:16
					gadget_grid[34] <= EMPTY;
					gadget_grid[35] <= EMPTY;
					gadget_grid[50] <= EMPTY;
					gadget_grid[51] <= EMPTY;
					gadget_grid[44] <= EMPTY;
					gadget_grid[45] <= EMPTY;
					gadget_grid[60] <= EMPTY;
					gadget_grid[61] <= EMPTY;
					gadget_grid[194] <= EMPTY;
					gadget_grid[195] <= EMPTY;
					gadget_grid[204] <= EMPTY;
					gadget_grid[205] <= EMPTY;
					gadget_grid[210] <= EMPTY;
					gadget_grid[211] <= EMPTY;
					gadget_grid[220] <= EMPTY;
					gadget_grid[221] <= EMPTY;
					
					//ABLE WALL: classify into HIDDEN state or EMPTY state
					//HIDDEN BOMB:28
					gadget_grid[4] <= HIDE_ADD_BOMB;
					gadget_grid[11] <= HIDE_ADD_BOMB;
					gadget_grid[18] <= HIDE_ADD_BOMB;
					gadget_grid[29] <= HIDE_ADD_BOMB;
					gadget_grid[32] <= HIDE_ADD_BOMB;
					gadget_grid[47] <= HIDE_ADD_BOMB;
					gadget_grid[208] <= HIDE_ADD_BOMB;
					gadget_grid[226] <= HIDE_ADD_BOMB;
					gadget_grid[244] <= HIDE_ADD_BOMB;
					gadget_grid[223] <= HIDE_ADD_BOMB;
					gadget_grid[237] <= HIDE_ADD_BOMB;
					gadget_grid[251] <= HIDE_ADD_BOMB;
					gadget_grid[8] <= HIDE_ADD_BOMB;
					gadget_grid[9] <= HIDE_ADD_BOMB;
					gadget_grid[40] <= HIDE_ADD_BOMB;
					gadget_grid[41] <= HIDE_ADD_BOMB;
					gadget_grid[70] <= HIDE_ADD_BOMB;
					gadget_grid[71] <= HIDE_ADD_BOMB;
					gadget_grid[102] <= HIDE_ADD_BOMB;
					gadget_grid[103] <= HIDE_ADD_BOMB;
					gadget_grid[136] <= HIDE_ADD_BOMB;
					gadget_grid[137] <= HIDE_ADD_BOMB;
					gadget_grid[168] <= HIDE_ADD_BOMB;
					gadget_grid[169] <= HIDE_ADD_BOMB;
					gadget_grid[198] <= HIDE_ADD_BOMB;
					gadget_grid[199] <= HIDE_ADD_BOMB;
					gadget_grid[230] <= HIDE_ADD_BOMB;
					gadget_grid[231] <= HIDE_ADD_BOMB;		
					
					//HIDDEN LOTION :12
					gadget_grid[19] <= HIDE_LOTION ;
					gadget_grid[28] <= HIDE_LOTION ;
					gadget_grid[33] <= HIDE_LOTION ;
					gadget_grid[46] <= HIDE_LOTION ;
					gadget_grid[80] <= HIDE_LOTION ;
					gadget_grid[81] <= HIDE_LOTION ;
					gadget_grid[174] <= HIDE_LOTION ;
					gadget_grid[175] <= HIDE_LOTION ;
					gadget_grid[209] <= HIDE_LOTION ;
					gadget_grid[222] <= HIDE_LOTION ;
					gadget_grid[227] <= HIDE_LOTION ;
					gadget_grid[236] <= HIDE_LOTION ;

					//ABLE WALL with nothin inside 
					gadget_grid[5] <= EMPTY ;
					gadget_grid[10] <= EMPTY ;
					gadget_grid[20] <= EMPTY ;
					gadget_grid[21] <= EMPTY ;
					gadget_grid[24] <= EMPTY ;
					gadget_grid[25] <= EMPTY ;
					gadget_grid[26] <= EMPTY ;
					gadget_grid[27] <= EMPTY ;
					gadget_grid[36] <= EMPTY ;
					gadget_grid[37] <= EMPTY ;
					gadget_grid[42] <= EMPTY ;
					gadget_grid[43] <= EMPTY ;
					gadget_grid[48] <= EMPTY ;
					gadget_grid[49] <= EMPTY ;
					gadget_grid[52] <= EMPTY ;
					gadget_grid[53] <= EMPTY ;
					gadget_grid[56] <= EMPTY ;
					gadget_grid[57] <= EMPTY ;
					gadget_grid[58] <= EMPTY ;
					gadget_grid[59] <= EMPTY ;
					gadget_grid[62] <= EMPTY ;
					gadget_grid[63] <= EMPTY ;
					gadget_grid[64] <= EMPTY ;
					gadget_grid[65] <= EMPTY ;
					gadget_grid[66] <= EMPTY ;
					gadget_grid[67] <= EMPTY ;
					gadget_grid[68] <= EMPTY ;
					gadget_grid[69] <= EMPTY ;
					gadget_grid[74] <= EMPTY ;
					gadget_grid[75] <= EMPTY ;
					gadget_grid[76] <= EMPTY ;
					gadget_grid[77] <= EMPTY ;
					gadget_grid[78] <= EMPTY ;
					gadget_grid[79] <= EMPTY ;
					gadget_grid[82] <= EMPTY ;
					gadget_grid[83] <= EMPTY ;
					gadget_grid[84] <= EMPTY ;
					gadget_grid[85] <= EMPTY ;
					gadget_grid[86] <= EMPTY ;
					gadget_grid[87] <= EMPTY ;
					gadget_grid[90] <= EMPTY ;
					gadget_grid[91] <= EMPTY ;
					gadget_grid[92] <= EMPTY ;
					gadget_grid[93] <= EMPTY ;
					gadget_grid[94] <= EMPTY ;
					gadget_grid[95] <= EMPTY ;
					gadget_grid[96] <= EMPTY ;
					gadget_grid[97] <= EMPTY ;
					gadget_grid[98] <= EMPTY ;
					gadget_grid[99] <= EMPTY ;
					gadget_grid[100] <= EMPTY ;
					gadget_grid[101] <= EMPTY ;
					gadget_grid[106] <= EMPTY ;
					gadget_grid[107] <= EMPTY ;
					gadget_grid[108] <= EMPTY ;
					gadget_grid[109] <= EMPTY ;
					gadget_grid[110] <= EMPTY ;
					gadget_grid[111] <= EMPTY ;
					gadget_grid[112] <= EMPTY ;
					gadget_grid[113] <= EMPTY ;
					gadget_grid[114] <= EMPTY ;
					gadget_grid[115] <= EMPTY ;
					gadget_grid[116] <= EMPTY ;
					gadget_grid[117] <= EMPTY ;
					gadget_grid[118] <= EMPTY ;
					gadget_grid[119] <= EMPTY ;
					gadget_grid[122] <= EMPTY ;
					gadget_grid[123] <= EMPTY ;
					gadget_grid[124] <= EMPTY ;
					gadget_grid[125] <= EMPTY ;
					gadget_grid[126] <= EMPTY ;
					gadget_grid[127] <= EMPTY ;
					gadget_grid[128] <= EMPTY ;
					gadget_grid[129] <= EMPTY ;
					gadget_grid[130] <= EMPTY ;
					gadget_grid[131] <= EMPTY ;
					gadget_grid[132] <= EMPTY ;
					gadget_grid[133] <= EMPTY ;
					gadget_grid[138] <= EMPTY ;
					gadget_grid[139] <= EMPTY ;
					gadget_grid[140] <= EMPTY ;
					gadget_grid[141] <= EMPTY ;
					gadget_grid[142] <= EMPTY ;
					gadget_grid[143] <= EMPTY ;
					gadget_grid[144] <= EMPTY ;
					gadget_grid[145] <= EMPTY ;
					gadget_grid[146] <= EMPTY ;
					gadget_grid[147] <= EMPTY ;
					gadget_grid[148] <= EMPTY ;
					gadget_grid[149] <= EMPTY ;
					gadget_grid[152] <= EMPTY ;
					gadget_grid[153] <= EMPTY ;
					gadget_grid[154] <= EMPTY ;
					gadget_grid[155] <= EMPTY ;
					gadget_grid[156] <= EMPTY ;
					gadget_grid[157] <= EMPTY ;
					gadget_grid[158] <= EMPTY ;
					gadget_grid[159] <= EMPTY ;
					gadget_grid[160] <= EMPTY ;
					gadget_grid[161] <= EMPTY ;
					gadget_grid[162] <= EMPTY ;
					gadget_grid[163] <= EMPTY ;
					gadget_grid[164] <= EMPTY ;
					gadget_grid[165] <= EMPTY ;
					gadget_grid[170] <= EMPTY ;
					gadget_grid[171] <= EMPTY ;
					gadget_grid[172] <= EMPTY ;
					gadget_grid[173] <= EMPTY ;
					gadget_grid[176] <= EMPTY ;
					gadget_grid[177] <= EMPTY ;
					gadget_grid[178] <= EMPTY ;
					gadget_grid[179] <= EMPTY ;
					gadget_grid[180] <= EMPTY ;
					gadget_grid[181] <= EMPTY ;
					gadget_grid[184] <= EMPTY ;
					gadget_grid[185] <= EMPTY ;
					gadget_grid[186] <= EMPTY ;
					gadget_grid[187] <= EMPTY ;
					gadget_grid[188] <= EMPTY ;
					gadget_grid[189] <= EMPTY ;
					gadget_grid[190] <= EMPTY ;
					gadget_grid[191] <= EMPTY ;
					gadget_grid[192] <= EMPTY ;
					gadget_grid[193] <= EMPTY ;
					gadget_grid[196] <= EMPTY ;
					gadget_grid[197] <= EMPTY ;
					gadget_grid[202] <= EMPTY ;
					gadget_grid[203] <= EMPTY ;
					gadget_grid[206] <= EMPTY ;
					gadget_grid[207] <= EMPTY ;
					gadget_grid[212] <= EMPTY ;
					gadget_grid[213] <= EMPTY ;
					gadget_grid[214] <= EMPTY ;
					gadget_grid[215] <= EMPTY ;
					gadget_grid[218] <= EMPTY ;
					gadget_grid[219] <= EMPTY ;
					gadget_grid[228] <= EMPTY ;
					gadget_grid[229] <= EMPTY ;
					gadget_grid[234] <= EMPTY ;
					gadget_grid[235] <= EMPTY ;
					gadget_grid[245] <= EMPTY ;
					gadget_grid[246] <= EMPTY ;
					gadget_grid[247] <= EMPTY ;
					gadget_grid[250] <= EMPTY ;
				end
				EE:
				begin
					//gadget
					for(ii = 0; ii<256; ii = ii+1) begin
						gadget_grid[ii] <= EMPTY;
					end

					gadget_grid[81] <= HIDE_ADD_BOMB;
					gadget_grid[97] <= HIDE_ADD_BOMB;
					gadget_grid[161] <= HIDE_ADD_BOMB;
					gadget_grid[177] <= HIDE_ADD_BOMB;
					gadget_grid[193] <= HIDE_ADD_BOMB;
					gadget_grid[194] <= HIDE_ADD_BOMB;
					gadget_grid[195] <= HIDE_ADD_BOMB;
					gadget_grid[29] <= HIDE_ADD_BOMB;
					gadget_grid[30] <= HIDE_ADD_BOMB;
					gadget_grid[46] <= HIDE_ADD_BOMB;

					gadget_grid[113] <= HIDE_LOTION;
					gadget_grid[129] <= HIDE_LOTION;
					gadget_grid[216] <= HIDE_LOTION;
					gadget_grid[217] <= HIDE_LOTION;
					gadget_grid[218] <= HIDE_LOTION;
					gadget_grid[28] <= HIDE_LOTION;
					gadget_grid[45] <= HIDE_LOTION;
					gadget_grid[62] <= HIDE_LOTION;
					gadget_grid[145] <= HIDE_LOTION;
					gadget_grid[196] <= HIDE_LOTION;
					gadget_grid[200] <= HIDE_LOTION;
					gadget_grid[215] <= HIDE_LOTION;
					gadget_grid[219] <= HIDE_LOTION;

				end
				LOVE_DCLAB:
				begin
					//gadget
					for(ii = 0; ii < 256; ii = ii+1) begin
						gadget_grid[ii] <= EMPTY;
					end
					gadget_grid[2] <= HIDE_ADD_BOMB;
					gadget_grid[10] <= HIDE_ADD_BOMB;
					gadget_grid[11] <= HIDE_ADD_BOMB;
					gadget_grid[27] <= HIDE_ADD_BOMB;
					gadget_grid[82] <= HIDE_ADD_BOMB;
					gadget_grid[99] <= HIDE_ADD_BOMB;
					gadget_grid[114] <= HIDE_ADD_BOMB;
					gadget_grid[116] <= HIDE_ADD_BOMB;
					gadget_grid[106] <= HIDE_ADD_BOMB;
					gadget_grid[107] <= HIDE_ADD_BOMB;
					gadget_grid[132] <= HIDE_ADD_BOMB;
					gadget_grid[133] <= HIDE_ADD_BOMB;
					gadget_grid[180] <= HIDE_ADD_BOMB;
					gadget_grid[197] <= HIDE_ADD_BOMB;
					gadget_grid[213] <= HIDE_ADD_BOMB;
					gadget_grid[168] <= HIDE_ADD_BOMB;
					gadget_grid[184] <= HIDE_ADD_BOMB;
					gadget_grid[201] <= HIDE_ADD_BOMB;
					gadget_grid[217] <= HIDE_ADD_BOMB;
					gadget_grid[235] <= HIDE_ADD_BOMB;
					gadget_grid[74] <= HIDE_ADD_BOMB;
					gadget_grid[89] <= HIDE_ADD_BOMB;
					gadget_grid[157] <= HIDE_ADD_BOMB;
					gadget_grid[78] <= HIDE_ADD_BOMB;
					gadget_grid[79] <= HIDE_ADD_BOMB;

					gadget_grid[98] <= HIDE_LOTION;
					gadget_grid[115] <= HIDE_LOTION;
					gadget_grid[90] <= HIDE_LOTION;
					gadget_grid[105] <= HIDE_LOTION;
					gadget_grid[120] <= HIDE_LOTION;
					gadget_grid[136] <= HIDE_LOTION;
					gadget_grid[212] <= HIDE_LOTION;
					gadget_grid[185] <= HIDE_LOTION;
					gadget_grid[158] <= HIDE_LOTION;
					gadget_grid[63] <= HIDE_LOTION;
					gadget_grid[77] <= HIDE_LOTION;
					gadget_grid[219] <= HIDE_LOTION;
					
				end
				default:
				begin
					for(ii = 0; ii < 256; ii = ii+1)begin
						gadget_grid[ii] <= EMPTY;
					end
				end
			endcase


		end 
		else begin
			for(iii=0; iii < 256; iii = iii+1)begin
				gadget_grid[iii] <= gadget_n[iii];
				gadget_ctr[iii] <= gadget_ctr_nxt[iii];
			end
			o_p1_cap <= p1_cap_nxt;
			o_p2_cap <= p2_cap_nxt;
			o_p1_len <= p1_len_nxt;
			o_p2_len <= p2_len_nxt;
		end
	end
endmodule // Gadget