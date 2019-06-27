module  p2_iconROM
(       input clk,
        input logic [11:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:60*60-1];


initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/angry_2_small.txt", mem0);   
end



always_ff @(posedge clk )
begin
    data_Out<= mem0[read_address];
end

endmodule
