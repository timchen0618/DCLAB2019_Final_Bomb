module  numberROM
(       input clk,
		input [1:0] state,
        input logic [11:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:30*120-1];
logic [3:0] mem1 [0:30*120-1];
logic [3:0] mem2 [0:30*120-1];
logic [3:0] mem3 [0:30*120-1];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/11.txt", mem0);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/22.txt", mem1);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/33.txt", mem2);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/44.txt", mem3);   

end



always_ff @(posedge clk )
begin
	case(state)
		0: data_Out<= mem0[read_address];
		1: data_Out<= mem1[read_address];
		2: data_Out<= mem2[read_address];
		3: data_Out<= mem3[read_address];
	endcase // state
    
end

endmodule
