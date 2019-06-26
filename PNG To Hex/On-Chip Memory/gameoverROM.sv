module  gameoverROM
(       input clk,
        input logic [18:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:640*480-1];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/GOheader.txt", mem0);   
end



always_ff @(posedge clk )
begin
    data_Out<= mem0[read_address];
end

endmodule
