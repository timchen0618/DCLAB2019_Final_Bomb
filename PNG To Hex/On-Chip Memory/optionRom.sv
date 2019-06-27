module  optionROM
(       input clk,
		input [1:0] option,
		input [1:0] option_ctr,
        input logic [13:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:60*150-1];
logic [3:0] mem1 [0:60*150-1];
logic [3:0] mem2 [0:60*150-1];
logic [3:0] mem3 [0:60*150-1];
logic [3:0] mem4 [0:60*150-1];
logic [3:0] mem5 [0:60*150-1];
logic [3:0] mem6 [0:60*150-1];
logic [3:0] mem7 [0:60*150-1];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt11_1.txt", mem0);  
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt22_2.txt", mem1);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt33_3.txt", mem2);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt44_4.txt", mem3);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt11.txt", mem4);  
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt22.txt", mem5);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt33.txt", mem6);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/opt44.txt", mem7);   

end



always_ff @(posedge clk )
begin
	case(option)
		0: begin 
			if(option_ctr == 0) data_Out<= mem4[read_address];
			else data_Out<= mem0[read_address];
		end 
		1: begin 
			if(option_ctr == 1) data_Out<= mem5[read_address];
			else data_Out<= mem1[read_address];
		end 
		2: begin 
			if(option_ctr == 2) data_Out<= mem6[read_address];
			else data_Out<= mem2[read_address];
		end 
		3: begin 
			if(option_ctr == 3) data_Out<= mem7[read_address];
			else data_Out<= mem3[read_address];
		end 
    endcase // option
end

endmodule
