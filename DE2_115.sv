module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
	
	
	logic [7:0] vga_r, vga_g, vga_b;
	logic [9:0] drawX, drawY;
	logic [3:0] StateArray [0:255];
	logic clock_vga, clock_vga_next;
	logic [3:0] p1_tile_x, p2_tile_x ,p1_tile_y, p2_tile_y;
	logic [1:0] p1_direction, p2_direction;
	logic Start;

	assign p1_tile_x = 4'd0;
	assign p2_tile_x = 4'd0;
	assign p1_tile_y = 4'd1;
	assign p2_tile_y = 4'd2;

	assign p1_direction = 2'd1;
	assign p2_direction = 2'd2;

	assign VGA_CLK = clock_vga;
	assign VGA_G = vga_g;
	assign VGA_R = vga_r;
	assign VGA_B = vga_b;


	always_ff @(posedge CLOCK_50 or posedge SW[0]) begin 
		if(SW[0]) begin
			clock_vga <= 0;
		end else begin
			clock_vga <= clock_vga_next;
		end
	end

	always_comb begin
		clock_vga_next = ~clock_vga;
	end

	assign LEDR[10] = SW[0];

	//#######################Tim#####################################//
	wire [7:0] data_in;
	wire data_done;
	wire [2:0] dir1;
	wire [2:0] dir2;
	wire set_bomb1;
	wire set_bomb2;
	wire data_valid1;
	wire data_valid2;

	logic clk3000;
	logic clk_30;
	//logic game_over;
	logic [2:0] state_dis;
	ps2_controller ps21(
		.clk(clk_30),
		.rst(SW[0]),
		.rx_data(data_in),
		.rx_done_tick(data_done),
		.direction_1(dir1),
		.direction_2(dir2),
		.bomb_1(set_bomb1),
		.bomb_2(set_bomb2),
		.out_valid_1(data_valid1),
		.out_valid_2(data_valid2),
		.rx_success(rx_suc),
		.out1(out1_rx),		
		.out2(out2_rx),		
		.out3(out3_rx),		
		.out4(out4_rx),
		.start(Start),
		.state_o(state_dis),
		.begin_(Beginnnn)		
	);

	//wire [255:0] wall;
	wire [2:0] bomb_num_1_in;
	wire [2:0] bomb_num_2_in;
	wire [3:0] p1_x_o, p2_x_o, p1_y_o, p2_y_o;
	//wire [7:0] p1_coordinate_display, p2_coordinate_display;
	wire [1:0] dir1_display, dir2_display;
	wire [3:0] bomb_num_display;
	wire [3:0] bomb_max_display;

	//new wire
	wire [255:0] wall;
	wire [2:0] gadget_grid [0:255];
	wire [2:0] bomb_grid [0:255];
	wire [2:0] wall_grid [0:255];
	wire [1:0] p1_bomb_len, p2_bomb_len;
	wire [2:0] p1_bomb_cap, p2_bomb_cap;
	wire [7:0] p1_cor, p2_cor;
	wire p1_put, p2_put;
	wire [255:0] explode;
	// wire [2:0] p1_cap;
	// wire [2:0] p2_cap;
	// wire [1:0] p1_len;
	// wire [1:0] p2_len;
	logic rx_suc;
	logic clk_6;
	logic in_valid_1_display;
	logic in_valid_2_display;
	logic bomb_valid1_display;
	logic [8:0] next_cor;
	logic [3:0] out1_rx, out2_rx, out3_rx, out4_rx;
	// logic start_out_ps2;

	logic Begin;
	logic Beginnnn;
	logic [1:0] option_ctr;

	ps2_rx ps2_rx1
	(
		.clk(CLOCK_50),
		// .rst(SW[0]),
		.reset(SW[0]),
		.ps2d(PS2_DAT),
		.ps2c(PS2_CLK),
		.rx_en(~SW[0]),    // ps2 data and clock inputs, receive enable input
		.rx_success(rx_suc),
		.rx_done_tick(data_done),         // ps2 receive done tick
		.rx_data(data_in)        // data received 
	);

	controller controller1
	(
		.clk(clk_30),
		// .rst(SW[0]),
		.rst(SW[0]),
		.direction_1(dir1),
		.direction_2(dir2),
		.bomb_1(set_bomb1),
		.bomb_2(set_bomb2),
		.in_valid_1(data_valid1),
		.in_valid_2(data_valid2),
		.i_wall(wall_grid),
		.bomb_max_1(p1_bomb_cap),
		.bomb_max_2(p2_bomb_cap),
		.bomb_num_1(bomb_num_1_in),
		.bomb_num_2(bomb_num_2_in),
		.bomb_wall_in(bomb_wall),

		.p1_set_bomb(p1_put),
		.p2_set_bomb(p2_put),
		.p1_x(p1_x_o),
		.p1_y(p1_y_o),
		.p2_x(p2_x_o),
		.p2_y(p2_y_o),
		.p1_coordinate_o(p1_cor),
		.p2_coordinate_o(p2_cor),
		.direction_1_o(dir1_display),
		.direction_2_o(dir2_display),

		.bomb_num_o1(bomb_num_display),
		.bomb_max_1_o(bomb_max_display),
		.in_valid_1_dis(in_valid_1_display),
		.in_valid_2_dis(in_valid_2_display),
		.p1_coordinate_next_o(next_cor),
		.bomb_valid1_o(bomb_valid1_display),
		.i_start(Beginnnn)

	);

	final_qsys final_qsys1(
		.clk_clk(CLOCK_50),       //     clk.clk
		.clk5000_clk(clk3000),   // clk5000.clk
		.reset_reset_n(~SW[0])  //   reset.reset_n
	);

	gen_clk30 gen_clk30_1(
		.clk(clk3000),    // Clock
		.rst(SW[0]),  // Asynchronous reset active low
		.clk_o(clk_30)
	);

	gen_clk6 genclk6(
	.clk(clk_30),    // Clock
	.rst(SW[0]),  // Asynchronous reset active low
	.clk_o(clk_6)
	);

	option option1(
    .clk(clk_30), 
    .rst(SW[0]),
    .i_start(Start), 
    .direction_1(dir1),	// key pressed
	.direction_2(dir2),	// key pressed
    .in_valid_1(data_valid1),
	.in_valid_2(data_valid2),
    .opt_ctr(option_ctr),
    .select(Begin)
	);
	
	assign LEDR[8] = rx_suc;
	assign LEDG[8] = data_valid1;
	assign LEDR[16] = Beginnnn;

	
	//#################################################################//
	logic [2:0] bomb_display1;
	logic bomb_display2;
	logic bomb_display3;
	logic bomb_display4;
	logic [5:0] bomb_p1_ctr_0;
	logic [3:0] bomb_p1_o;
	logic p2_able;
	logic [3:0] p1_put_ctr_display;
	logic [2:0] game_state;
	logic [255:0] bomb_wall;

	Picture_Output picture_output(
		.clk(CLOCK_50),
		.reset(SW[0]),
		.gadget_grid(gadget_grid) ,
		.bomb_grid(bomb_grid) ,
		.wall_grid(wall_grid),
		.occ_grid(StateArray)
		);

	bomb bomb(
		.clk(clk_30),
		.reset(SW[0]),
		.p1_bomb_len(p1_bomb_len), 
		.p2_bomb_len(p2_bomb_len),
		// .p1_bomb_cap(p1_bomb_cap),
		// .p2_bomb_cap(p2_bomb_cap),
		.p1_cor(p1_cor), 
		.p2_cor(p2_cor),
		.p1_put(p1_put), 
		.p2_put(p2_put),
		.bomb_tile(bomb_grid),
		.explode(explode),
		.bomb_num_p1(bomb_num_1_in),
		.bomb_num_p2(bomb_num_2_in),
		.display1(bomb_display1),
		.display2(bomb_display2),
		.display3(bomb_display3),
		.display4(bomb_display4),
		.bomb_p1_ctr_0(bomb_p1_ctr_0),
		.bomb_p1_o(bomb_p1_o),
		.p1_put_ctr(p1_put_ctr_display),
		.bomb_un_grid(bomb_wall),
		.wall_grid(wall_grid)
		);

	// assign LEDR[2] = bomb_display1;
	assign LEDR[3] = bomb_display2;
	assign LEDR[4] = bomb_display3;
	assign LEDR[5] = bomb_display4;
	assign LEDR[6] = in_valid_1_display;
	assign LEDR[7] = in_valid_2_display;
	assign LEDR[17] = bomb_valid1_display;
	//assign LEDR[10] = p1_put;
	//assign LEDR[16] = wall[4]; 

	Wall Wall(
		.clk(clk_30),    // Clock
		.start(Beginnnn),  // Asynchronous reset active low
		.rst(SW[0]),
		.i_explode(explode),
		.wall_type(option_ctr),
	 	.wall_grid(wall_grid)
	 	//.o_wall(wall) 
		);

	Gadget gadget(
		.clk(clk_30),
		.start(Beginnnn),
		.rst(SW[0]),
		.gadget_type(option_ctr),
		.p1_cor(p1_cor),
		.p2_cor(p2_cor),
		.i_explode(explode),

	//output to keyboard control
		.o_p1_cap(p1_bomb_cap), //bomb number
		.o_p2_cap(p2_bomb_cap),

	//output to BOMB control
		.o_p1_len(p1_bomb_len), //bomb len
		.o_p2_len(p2_bomb_len),

	//output to display
		.gadget_grid(gadget_grid),

	//output for debug 
		.p2_able_to_add_bomb(p2_able)
		);

	Gameover game_over(
		.clk(clk_30),
		.reset(SW[0]),
		.i_explode(explode),
		.p1_cor(p1_cor),
		.p2_cor(p2_cor),
		//state
		.gameover_state(game_state),
		.Start(Start),
		.Begin(Begin)
		); 
	
	color_mapper  color_mapper ( 
		.clk(CLOCK_50),
		.rst(SW[0]),
		.p1_tile_x(p1_x_o),
        .p2_tile_x(p2_x_o),
        .p1_tile_y(p1_y_o),
        .p2_tile_y(p2_y_o),
		.StateArray(StateArray),
        .DrawX(drawX),
        .DrawY(drawY),    
        .VGA_R(vga_r),
        .VGA_G(vga_g), 
        .VGA_B(vga_b),
        .gameStatus(game_state), 
        .o_p1_cap(p1_bomb_cap), 
        .o_p2_cap(p2_bomb_cap),
        .o_p1_len(p1_bomb_len), 
        .o_p2_len(p2_bomb_len),
        .option_ctr(option_ctr),
        .Begin_i(Begin),
        .Beginnnn_o(Beginnnn)
    );

    VGA_controller vga_controller(
    	.Clk(CLOCK_50),         // 50 MHz clock
        .Reset(SW[0]),       // Active-high reset signal
	    .VGA_HS(VGA_HS),      // Horizontal sync pulse.  Active low
	    .VGA_VS(VGA_VS),      // Vertical sync pulse.  Active low
	    .VGA_CLK(clock_vga),     // 25 MHz VGA clock input
	    .VGA_BLANK_N(VGA_BLANK_N), // Blanking interval indicator.  Active low.
	    .VGA_SYNC_N(VGA_SYNC_N),  // Composite Sync signal.  Active low.  We don't use it in this lab,
	    .DrawX(drawX),       // horizontal coordinate
	    .DrawY(drawY)        // vertical coordinate
    );   

 //    SevenHexDecoder seven_dec0(
	// 	.i_hex(next_cor[3:0]),
	// 	.o_seven_ten(HEX1),
	// 	.o_seven_one(HEX0)
	// );

	// SevenHexDecoder seven_dec1(
	// 	.i_hex(next_cor[7:4]),
	// 	.o_seven_ten(HEX3),
	// 	.o_seven_one(HEX2)
	// );

	// SevenHexDecoder seven_dec2(
	// 	.i_hex(p2_x_o),
	// 	.o_seven_ten(HEX5),
	// 	.o_seven_one(HEX4)
	// );

	// SevenHexDecoder seven_dec3(
	// 	.i_hex(p2_y_o),
	// 	.o_seven_ten(HEX7),
	// 	.o_seven_one(HEX6)
	// );

	SevenHexDecoder seven_dec0(
		.i_hex(state_dis),
		.o_seven_ten(HEX1),
		.o_seven_one(HEX0)
	);

	SevenHexDecoder seven_dec1(
		.i_hex(bomb_num_1_in),
		.o_seven_ten(HEX3),
		.o_seven_one(HEX2)
	);

	SevenHexDecoder seven_dec2(
		.i_hex(p2_bomb_cap),
		.o_seven_ten(HEX5),
		.o_seven_one(HEX4)
	);

	SevenHexDecoder seven_dec3(
		.i_hex(option_ctr),
		.o_seven_ten(HEX7),
		.o_seven_one(HEX6)
	);
	assign LEDR[0] = p1_put;
	assign LEDR[1] = p2_put;

`ifdef DUT_LAB_FINAL
	initial begin
		$fsdbDumpfile("LAB_FINAL.fsdb");
		$fsdbDumpvars(0, DE2_115, "+mda");
	end
`endif
endmodule
