`timescale 1ns / 1ps

module tb_CU();
reg tb_Go, tb_clk;
reg [1:0] tb_Op;

wire [13:0] tb_ctrl;
wire [3:0] tb_State;
wire tb_Done;

integer i, j;
//reg [3:0] tb_CS;

// list of expected states for testing purposes
// S1 WA WE RAA REA RAB REB C  S2 DONE STATE
// 00 00 0  00  0   00  0   00 0  0    0000
reg [18:0] tb_S0 = 19'b01_00_0_00_0_00_0_00_0_0_0000;
reg [18:0] tb_S1 = 19'b11_01_1_00_0_00_0_00_0_0_0001;
reg [18:0] tb_S2 = 19'b10_10_1_00_0_00_0_00_0_0_0010;
reg [18:0] tb_S3 = 19'b01_00_0_00_0_00_0_00_0_0_0011;
reg [18:0] tb_S4 = 19'b00_11_1_01_1_10_1_00_0_0_0100;
reg [18:0] tb_S5 = 19'b00_11_1_01_1_10_1_01_0_0_0101;
reg [18:0] tb_S6 = 19'b00_11_1_01_1_10_1_10_0_0_0110;
reg [18:0] tb_S7 = 19'b00_11_1_01_1_10_1_11_0_0_0111;
reg [18:0] tb_S8 = 19'b01_00_0_11_1_11_1_10_1_1_1000;
reg [18:0] test;
reg [18:0] expected;

CU DUT (.Go(tb_Go), .Op(tb_Op), .clk(tb_clk), .ctrl_sig(tb_ctrl), .State(tb_State), .Done(tb_Done));

initial
begin
	tb_Go = 0;
	tb_clk = 1;
	#5;
	tb_clk = 0;
	#5;

	tb_Go = 1;

	for(i = 0; i <= 3; i = i + 1) //setting Op code for test
	begin
		tb_Op = i;

		for(j = 0; j <= 5; j = j + 1) // setting state for test
		begin
			//tb_CS = j;
			tb_clk = 1;
			#5;
			tb_clk = 0;
			#5;
			test = {tb_ctrl, tb_Done, tb_State};

			case(tb_State)
				0: expected = tb_S0;
				1: expected = tb_S1;
				2: expected = tb_S2;
				3: expected = tb_S3;
				4: expected = tb_S4;
				5: expected = tb_S5;
				6: expected = tb_S6;
				7: expected = tb_S7;
				8: expected = tb_S8;
			endcase
			
			if(test != expected)
			begin
				$display ("Error at state %1d", j);
				$stop;
			end
		end
	end
	tb_clk = 1;
	#5;
	tb_clk = 0;
	#5;
	$display ("Success");
end

endmodule
