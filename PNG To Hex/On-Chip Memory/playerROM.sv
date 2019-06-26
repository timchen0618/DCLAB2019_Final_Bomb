module  playerROM
(       input clk,
        input player,
        input logic [9:0] read_address,
		output logic [3:0] data_Out
);



logic [3:0] mem0 [0:899];
logic [3:0] mem1 [0:899];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/p1.txt", mem0);   
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/p2.txt", mem1);   
end



always_ff @(posedge clk )
begin
        if(~player) begin  // player 2
            data_Out<= mem0[read_address];
        end
        else begin  // player 1
            data_Out<= mem1[read_address];
        end

end

endmodule
