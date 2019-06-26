module Gadget(
	//input
	input clk,
	input rst,
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
	output logic [2:0] o_gadget_state_grid[0:255],

	//output for debug
	output p2_able_to_add_bomb

	);

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

	integer i,idx,index;
	//input logic 
	always_comb begin
		p1_len_nxt = o_p1_len;
		p2_len_nxt = o_p2_len;
		p1_cap_nxt = o_p1_cap;
		p2_cap_nxt = o_p2_cap;

		if(o_gadget_state_grid[p1_cor] == LOTION)begin
			if(p1_able_to_add_len == 1'd1) begin
				p1_len_nxt  = o_p1_len + 2'd1;
			end
			else p1_len_nxt = 2'd3;
		end

		if(o_gadget_state_grid[p2_cor] == LOTION)begin
			if(p1_cor != p2_cor) begin
				if(p2_able_to_add_len == 1'd1) begin
					p2_len_nxt  = o_p2_len + 2'd1;
				end
				else p2_len_nxt = 2'd3;
			end
			
		end	

		if(o_gadget_state_grid[p1_cor] == ADD_BOMB)begin
			if(p1_able_to_add_bomb == 1'd1)begin
				p1_cap_nxt = o_p1_cap + 2'd1;
			end
			else p1_cap_nxt = 3'd4;
		end
		
		if(o_gadget_state_grid[p2_cor] == ADD_BOMB)begin
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
			gadget_n[idx] = o_gadget_state_grid[idx];
			gadget_ctr_nxt[idx] = gadget_ctr[idx];
			
			case(o_gadget_state_grid[idx]) 
				EMPTY:
				begin
					gadget_n[idx] = o_gadget_state_grid[idx];
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
							gadget_n[idx] = o_gadget_state_grid[idx];
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
							gadget_n[idx] = o_gadget_state_grid[idx];
						end
					end
				end
				HIDE_LOTION:
				begin
					if(i_explode[idx] == 1'd1)begin
						if(gadget_ctr[idx] >= 6'd30) begin
							gadget_n[idx] = LOTION;
							gadget_ctr_nxt[idx] = 0;
						end
						else begin
							gadget_ctr_nxt[idx] = gadget_ctr[idx] + 1;
							gadget_n[idx] = o_gadget_state_grid[idx];
						end
					end
					else begin
						gadget_n[idx] = o_gadget_state_grid[idx];
					end
				end
				HIDE_ADD_BOMB:
				begin
					if(i_explode[idx] == 1'd1) begin
						if(gadget_ctr[idx] >= 6'd30) begin
							gadget_n[idx] = ADD_BOMB;
							gadget_ctr_nxt[idx] = 0;
						end
						else begin
							gadget_ctr_nxt[idx] = gadget_ctr[idx] + 1;
							gadget_n[idx] = o_gadget_state_grid[idx];
						end

					end
					else begin
						gadget_n[idx] = o_gadget_state_grid[idx];
					end
				end
				default:
				begin
					gadget_n[idx] = o_gadget_state_grid[idx];
					// p1_cap_nxt = o_p1_cap;
					// p2_cap_nxt = o_p2_cap;
					// p1_len_nxt = o_p1_len;
					// p2_len_nxt = o_p2_len;
				end
			endcase
		end
	end 

	always_ff @(posedge clk or posedge rst) begin 
		if(rst) begin
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
			o_gadget_state_grid[0] <= EMPTY;
			o_gadget_state_grid[1] <= EMPTY;
			o_gadget_state_grid[2] <= EMPTY;
			o_gadget_state_grid[3] <= EMPTY;
			o_gadget_state_grid[6] <= EMPTY;
			o_gadget_state_grid[7] <= EMPTY;
			o_gadget_state_grid[12] <= EMPTY;
			o_gadget_state_grid[13] <= EMPTY;
			o_gadget_state_grid[14] <= EMPTY;
			o_gadget_state_grid[15] <= EMPTY;
			o_gadget_state_grid[16] <= EMPTY;
			o_gadget_state_grid[17] <= EMPTY;
			o_gadget_state_grid[22] <= EMPTY;
			o_gadget_state_grid[23] <= EMPTY;
			o_gadget_state_grid[30] <= EMPTY;
			o_gadget_state_grid[31] <= EMPTY;
			o_gadget_state_grid[38] <= EMPTY;
			o_gadget_state_grid[39] <= EMPTY;
			o_gadget_state_grid[54] <= EMPTY;
			o_gadget_state_grid[55] <= EMPTY;
			o_gadget_state_grid[72] <= EMPTY;
			o_gadget_state_grid[73] <= EMPTY;
			o_gadget_state_grid[88] <= EMPTY;
			o_gadget_state_grid[89] <= EMPTY;
			o_gadget_state_grid[104] <= EMPTY;
			o_gadget_state_grid[105] <= EMPTY;
			o_gadget_state_grid[120] <= EMPTY;
			o_gadget_state_grid[121] <= EMPTY;
			o_gadget_state_grid[134] <= EMPTY;
			o_gadget_state_grid[135] <= EMPTY;
			o_gadget_state_grid[150] <= EMPTY;
			o_gadget_state_grid[151] <= EMPTY;
			o_gadget_state_grid[166] <= EMPTY;
			o_gadget_state_grid[167] <= EMPTY;
			o_gadget_state_grid[182] <= EMPTY;
			o_gadget_state_grid[183] <= EMPTY;
			o_gadget_state_grid[200] <= EMPTY;
			o_gadget_state_grid[201] <= EMPTY;
			o_gadget_state_grid[216] <= EMPTY;
			o_gadget_state_grid[217] <= EMPTY;
			o_gadget_state_grid[224] <= EMPTY;
			o_gadget_state_grid[225] <= EMPTY;
			o_gadget_state_grid[232] <= EMPTY;
			o_gadget_state_grid[233] <= EMPTY;
			o_gadget_state_grid[238] <= EMPTY;
			o_gadget_state_grid[239] <= EMPTY;
			o_gadget_state_grid[240] <= EMPTY;
			o_gadget_state_grid[241] <= EMPTY;
			o_gadget_state_grid[242] <= EMPTY;
			o_gadget_state_grid[243] <= EMPTY;
			o_gadget_state_grid[248] <= EMPTY;
			o_gadget_state_grid[249] <= EMPTY;
			o_gadget_state_grid[252] <= EMPTY;
			o_gadget_state_grid[253] <= EMPTY;
			o_gadget_state_grid[254] <= EMPTY;
			o_gadget_state_grid[255] <= EMPTY;
			
			//UNABLE WALL: STILL display EMPTY:16
			o_gadget_state_grid[34] <= EMPTY;
			o_gadget_state_grid[35] <= EMPTY;
			o_gadget_state_grid[50] <= EMPTY;
			o_gadget_state_grid[51] <= EMPTY;
			o_gadget_state_grid[44] <= EMPTY;
			o_gadget_state_grid[45] <= EMPTY;
			o_gadget_state_grid[60] <= EMPTY;
			o_gadget_state_grid[61] <= EMPTY;
			o_gadget_state_grid[194] <= EMPTY;
			o_gadget_state_grid[195] <= EMPTY;
			o_gadget_state_grid[204] <= EMPTY;
			o_gadget_state_grid[205] <= EMPTY;
			o_gadget_state_grid[210] <= EMPTY;
			o_gadget_state_grid[211] <= EMPTY;
			o_gadget_state_grid[220] <= EMPTY;
			o_gadget_state_grid[221] <= EMPTY;
			
			//ABLE WALL: classify into HIDDEN state or EMPTY state
			//HIDDEN BOMB:28
			o_gadget_state_grid[4] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[11] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[18] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[29] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[32] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[47] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[208] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[226] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[244] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[223] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[237] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[251] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[8] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[9] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[40] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[41] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[70] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[71] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[102] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[103] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[136] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[137] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[168] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[169] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[198] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[199] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[230] <= HIDE_ADD_BOMB;
			o_gadget_state_grid[231] <= HIDE_ADD_BOMB;		
			
			//HIDDEN LOTION :12
			o_gadget_state_grid[19] <= HIDE_LOTION ;
			o_gadget_state_grid[28] <= HIDE_LOTION ;
			o_gadget_state_grid[33] <= HIDE_LOTION ;
			o_gadget_state_grid[46] <= HIDE_LOTION ;
			o_gadget_state_grid[80] <= HIDE_LOTION ;
			o_gadget_state_grid[81] <= HIDE_LOTION ;
			o_gadget_state_grid[174] <= HIDE_LOTION ;
			o_gadget_state_grid[175] <= HIDE_LOTION ;
			o_gadget_state_grid[209] <= HIDE_LOTION ;
			o_gadget_state_grid[222] <= HIDE_LOTION ;
			o_gadget_state_grid[227] <= HIDE_LOTION ;
			o_gadget_state_grid[236] <= HIDE_LOTION ;

			//ABLE WALL with nothin inside 
			o_gadget_state_grid[5] <= EMPTY ;
			o_gadget_state_grid[10] <= EMPTY ;
			o_gadget_state_grid[20] <= EMPTY ;
			o_gadget_state_grid[21] <= EMPTY ;
			o_gadget_state_grid[24] <= EMPTY ;
			o_gadget_state_grid[25] <= EMPTY ;
			o_gadget_state_grid[26] <= EMPTY ;
			o_gadget_state_grid[27] <= EMPTY ;
			o_gadget_state_grid[36] <= EMPTY ;
			o_gadget_state_grid[37] <= EMPTY ;
			o_gadget_state_grid[42] <= EMPTY ;
			o_gadget_state_grid[43] <= EMPTY ;
			o_gadget_state_grid[48] <= EMPTY ;
			o_gadget_state_grid[49] <= EMPTY ;
			o_gadget_state_grid[52] <= EMPTY ;
			o_gadget_state_grid[53] <= EMPTY ;
			o_gadget_state_grid[56] <= EMPTY ;
			o_gadget_state_grid[57] <= EMPTY ;
			o_gadget_state_grid[58] <= EMPTY ;
			o_gadget_state_grid[59] <= EMPTY ;
			o_gadget_state_grid[62] <= EMPTY ;
			o_gadget_state_grid[63] <= EMPTY ;
			o_gadget_state_grid[64] <= EMPTY ;
			o_gadget_state_grid[65] <= EMPTY ;
			o_gadget_state_grid[66] <= EMPTY ;
			o_gadget_state_grid[67] <= EMPTY ;
			o_gadget_state_grid[68] <= EMPTY ;
			o_gadget_state_grid[69] <= EMPTY ;
			o_gadget_state_grid[74] <= EMPTY ;
			o_gadget_state_grid[75] <= EMPTY ;
			o_gadget_state_grid[76] <= EMPTY ;
			o_gadget_state_grid[77] <= EMPTY ;
			o_gadget_state_grid[78] <= EMPTY ;
			o_gadget_state_grid[79] <= EMPTY ;
			o_gadget_state_grid[82] <= EMPTY ;
			o_gadget_state_grid[83] <= EMPTY ;
			o_gadget_state_grid[84] <= EMPTY ;
			o_gadget_state_grid[85] <= EMPTY ;
			o_gadget_state_grid[86] <= EMPTY ;
			o_gadget_state_grid[87] <= EMPTY ;
			o_gadget_state_grid[90] <= EMPTY ;
			o_gadget_state_grid[91] <= EMPTY ;
			o_gadget_state_grid[92] <= EMPTY ;
			o_gadget_state_grid[93] <= EMPTY ;
			o_gadget_state_grid[94] <= EMPTY ;
			o_gadget_state_grid[95] <= EMPTY ;
			o_gadget_state_grid[96] <= EMPTY ;
			o_gadget_state_grid[97] <= EMPTY ;
			o_gadget_state_grid[98] <= EMPTY ;
			o_gadget_state_grid[99] <= EMPTY ;
			o_gadget_state_grid[100] <= EMPTY ;
			o_gadget_state_grid[101] <= EMPTY ;
			o_gadget_state_grid[106] <= EMPTY ;
			o_gadget_state_grid[107] <= EMPTY ;
			o_gadget_state_grid[108] <= EMPTY ;
			o_gadget_state_grid[109] <= EMPTY ;
			o_gadget_state_grid[110] <= EMPTY ;
			o_gadget_state_grid[111] <= EMPTY ;
			o_gadget_state_grid[112] <= EMPTY ;
			o_gadget_state_grid[113] <= EMPTY ;
			o_gadget_state_grid[114] <= EMPTY ;
			o_gadget_state_grid[115] <= EMPTY ;
			o_gadget_state_grid[116] <= EMPTY ;
			o_gadget_state_grid[117] <= EMPTY ;
			o_gadget_state_grid[118] <= EMPTY ;
			o_gadget_state_grid[119] <= EMPTY ;
			o_gadget_state_grid[122] <= EMPTY ;
			o_gadget_state_grid[123] <= EMPTY ;
			o_gadget_state_grid[124] <= EMPTY ;
			o_gadget_state_grid[125] <= EMPTY ;
			o_gadget_state_grid[126] <= EMPTY ;
			o_gadget_state_grid[127] <= EMPTY ;
			o_gadget_state_grid[128] <= EMPTY ;
			o_gadget_state_grid[129] <= EMPTY ;
			o_gadget_state_grid[130] <= EMPTY ;
			o_gadget_state_grid[131] <= EMPTY ;
			o_gadget_state_grid[132] <= EMPTY ;
			o_gadget_state_grid[133] <= EMPTY ;
			o_gadget_state_grid[138] <= EMPTY ;
			o_gadget_state_grid[139] <= EMPTY ;
			o_gadget_state_grid[140] <= EMPTY ;
			o_gadget_state_grid[141] <= EMPTY ;
			o_gadget_state_grid[142] <= EMPTY ;
			o_gadget_state_grid[143] <= EMPTY ;
			o_gadget_state_grid[144] <= EMPTY ;
			o_gadget_state_grid[145] <= EMPTY ;
			o_gadget_state_grid[146] <= EMPTY ;
			o_gadget_state_grid[147] <= EMPTY ;
			o_gadget_state_grid[148] <= EMPTY ;
			o_gadget_state_grid[149] <= EMPTY ;
			o_gadget_state_grid[152] <= EMPTY ;
			o_gadget_state_grid[153] <= EMPTY ;
			o_gadget_state_grid[154] <= EMPTY ;
			o_gadget_state_grid[155] <= EMPTY ;
			o_gadget_state_grid[156] <= EMPTY ;
			o_gadget_state_grid[157] <= EMPTY ;
			o_gadget_state_grid[158] <= EMPTY ;
			o_gadget_state_grid[159] <= EMPTY ;
			o_gadget_state_grid[160] <= EMPTY ;
			o_gadget_state_grid[161] <= EMPTY ;
			o_gadget_state_grid[162] <= EMPTY ;
			o_gadget_state_grid[163] <= EMPTY ;
			o_gadget_state_grid[164] <= EMPTY ;
			o_gadget_state_grid[165] <= EMPTY ;
			o_gadget_state_grid[170] <= EMPTY ;
			o_gadget_state_grid[171] <= EMPTY ;
			o_gadget_state_grid[172] <= EMPTY ;
			o_gadget_state_grid[173] <= EMPTY ;
			o_gadget_state_grid[176] <= EMPTY ;
			o_gadget_state_grid[177] <= EMPTY ;
			o_gadget_state_grid[178] <= EMPTY ;
			o_gadget_state_grid[179] <= EMPTY ;
			o_gadget_state_grid[180] <= EMPTY ;
			o_gadget_state_grid[181] <= EMPTY ;
			o_gadget_state_grid[184] <= EMPTY ;
			o_gadget_state_grid[185] <= EMPTY ;
			o_gadget_state_grid[186] <= EMPTY ;
			o_gadget_state_grid[187] <= EMPTY ;
			o_gadget_state_grid[188] <= EMPTY ;
			o_gadget_state_grid[189] <= EMPTY ;
			o_gadget_state_grid[190] <= EMPTY ;
			o_gadget_state_grid[191] <= EMPTY ;
			o_gadget_state_grid[192] <= EMPTY ;
			o_gadget_state_grid[193] <= EMPTY ;
			o_gadget_state_grid[196] <= EMPTY ;
			o_gadget_state_grid[197] <= EMPTY ;
			o_gadget_state_grid[202] <= EMPTY ;
			o_gadget_state_grid[203] <= EMPTY ;
			o_gadget_state_grid[206] <= EMPTY ;
			o_gadget_state_grid[207] <= EMPTY ;
			o_gadget_state_grid[212] <= EMPTY ;
			o_gadget_state_grid[213] <= EMPTY ;
			o_gadget_state_grid[214] <= EMPTY ;
			o_gadget_state_grid[215] <= EMPTY ;
			o_gadget_state_grid[218] <= EMPTY ;
			o_gadget_state_grid[219] <= EMPTY ;
			o_gadget_state_grid[228] <= EMPTY ;
			o_gadget_state_grid[229] <= EMPTY ;
			o_gadget_state_grid[234] <= EMPTY ;
			o_gadget_state_grid[235] <= EMPTY ;
			o_gadget_state_grid[245] <= EMPTY ;
			o_gadget_state_grid[246] <= EMPTY ;
			o_gadget_state_grid[247] <= EMPTY ;
			o_gadget_state_grid[250] <= EMPTY ;

		end 
		else begin
			for(i=0; i < 256; i = i+1)begin
				o_gadget_state_grid[i] <= gadget_n[i];
				gadget_ctr[i] <= gadget_ctr_nxt[i];
			end
			o_p1_cap <= p1_cap_nxt;
			o_p2_cap <= p2_cap_nxt;
			o_p1_len <= p1_len_nxt;
			o_p2_len <= p2_len_nxt;
		end
	end
endmodule // Gadget