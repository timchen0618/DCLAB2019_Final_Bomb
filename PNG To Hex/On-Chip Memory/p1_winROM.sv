module  p1_winROM
(       input clk,
        input logic [9:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:899];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/p1.txt", mem0);   
end



always_ff @(posedge clk )
begin
    data_Out<= mem0[read_address];
end

endmodule
