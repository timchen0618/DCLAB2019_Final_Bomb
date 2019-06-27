module  backgroundROM
(       input clk,
		input logic [3:0] state,
        input logic [9:0] read_address,
		output logic [3:0] data_Out
);

//states for occ_grid ->display 
    //order priority: UP->RIGHT->DOWN->LEFT
    parameter OCC_NONE = 5'd0;
    parameter OCC_LOTION = 5'd1; // sth that can add bomb length
    parameter OCC_BOMB = 5'd2; // unxploded bomb
    parameter OCC_ADD_BOMB = 5'd3; // thing that can add bomb capacity
    parameter OCC_CEN = 5'd4;  // the center of the explosion 
    parameter OCC_UP = 5'd5;  
    parameter OCC_DOWN = 5'd6;  
    parameter OCC_LEFT = 5'd7;
    parameter OCC_RIGHT = 5'd8;
    parameter OCC_WALL_ABLE_1   = 5'd9;
    parameter OCC_WALL_ABLE_2   = 5'd10;
    parameter OCC_WALL_UN_1     = 5'd11;
    parameter OCC_WALL_UN_2     = 5'd12;

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem0 [0:899];
logic [3:0] mem1 [0:899];
logic [3:0] mem2 [0:899];
logic [3:0] mem3 [0:899];
logic [3:0] mem4 [0:899];
logic [3:0] mem5 [0:899];
logic [3:0] mem6 [0:899];
logic [3:0] mem7 [0:899];
logic [3:0] mem8 [0:899];
logic [3:0] mem9 [0:899];
logic [3:0] mem10 [0:899];
logic [3:0] mem11 [0:899];
logic [3:0] mem12 [0:899];



initial
begin
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/grass.txt", mem0);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/lotion.txt", mem1);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/waterball.txt", mem2);  
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/add_bomb.txt", mem3);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/bomb_center.txt", mem4);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/waterup.txt", mem5);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/waterdown.txt", mem6);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/waterleft.txt", mem7);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/waterright.txt", mem8);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/yellow.txt", mem9);
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/able_wall_2.txt", mem10);    
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/orange.txt", mem11);    
    $readmemh("./PNG To Hex/On-Chip Memory/sprite_bytes/unable_wall_2.txt", mem12);     
end



always_ff @(posedge clk )
begin
    case (state)
        OCC_NONE: data_Out<= mem0[read_address];
        OCC_LOTION: data_Out<= mem1[read_address]; 
        OCC_BOMB: data_Out<= mem2[read_address];
        OCC_ADD_BOMB: data_Out<= mem3[read_address]; 
        OCC_CEN: data_Out<= mem4[read_address];
        OCC_UP: data_Out<= mem5[read_address]; 
        OCC_DOWN: data_Out<= mem6[read_address];
        OCC_LEFT: data_Out<= mem7[read_address]; 
        OCC_RIGHT: data_Out<= mem8[read_address]; 
        OCC_WALL_ABLE_1: data_Out<= mem9[read_address]; 
        OCC_WALL_ABLE_2: data_Out<= mem10[read_address];
        OCC_WALL_UN_1: data_Out<= mem11[read_address]; 
        OCC_WALL_UN_2: data_Out<= mem12[read_address];
    endcase // state
end

endmodule
