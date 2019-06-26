module array_gen(
	input clk,
	input reset,
	output logic [4:0] stateArray [0:255]
);
	
	logic [4:0] stateArray_next [0:255];
	integer i;
	integer ii;
	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			for (i=0;i<20;i = i + 1) begin
				stateArray[i] <= 5'd0;
			end
			for (i=20;i<40;i = i + 1) begin
				stateArray[i] <= 5'd1;
			end
			for (i=40;i<60;i = i + 1) begin
				stateArray[i] <= 5'd2;
			end
			for (i=60;i<80;i = i + 1) begin
				stateArray[i] <= 5'd3;
			end
			for (i=80;i<100;i = i + 1) begin
				stateArray[i] <= 5'd4;
			end
			for (i=100;i<120;i = i + 1) begin
				stateArray[i] <= 5'd5;
			end
			for (i=120;i<140;i = i + 1) begin
				stateArray[i] <= 5'd6;
			end
			for (i=140;i<160;i = i + 1) begin
				stateArray[i] <= 5'd7;
			end
			for (i=160;i<180;i = i + 1) begin
				stateArray[i] <= 5'd8;
			end
			for (i=180;i<200;i = i + 1) begin
				stateArray[i] <= 5'd9;
			end
			for (i=200;i<220;i = i + 1) begin
				stateArray[i] <= 5'd10;
			end
		end 
		else begin
			for (i=0;i<256;i = i + 1) begin
				stateArray[i] <= stateArray_next[i];
			end
		end
	end

	always_comb begin 
		for (ii=0;ii<256;ii = ii + 1) begin
			stateArray_next[ii] = stateArray[ii];
		end
	end

	
endmodule