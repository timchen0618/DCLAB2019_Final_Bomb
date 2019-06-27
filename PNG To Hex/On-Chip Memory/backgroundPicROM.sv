module  backgroundPicROM
(       input clk,
        input logic [16:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:320*240-1];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/bg4.txt", mem0);   
end



always_ff @(posedge clk )
begin
    data_Out<= mem0[read_address];
end

endmodule
