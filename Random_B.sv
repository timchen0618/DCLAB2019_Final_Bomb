module Random_B(
	input  change, 
	input rst,
	output [7:0] rand_out
);
	parameter y0 = 8'd7;
	parameter a  = 8'd5;
	parameter c  = 8'd3;
	parameter m  = 8'd256;

	logic [10:0] current_num, next_num;

	//m=16、a=5、c=3、y0=7

	always_ff @(posedge change or negedge rst) 
	begin
		if (!rst) current_num <= y0;
		else current_num <= next_num;
	end

	always_comb
	begin
		//next_num = (current_num * a + c) % m;
		next_num = (current_num * a + c) - m * ((current_num * a + c) >> 8);
	end

	assign rand_out = current_num[7:0];
endmodule