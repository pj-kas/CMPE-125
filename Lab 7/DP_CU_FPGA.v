`timescale 1ns / 1ps

module DP_CU_FPGA(input [2:0] in_1, in_2,
				  input [1:0] Op_top,
				  input Go_top, clk100MHz, rst, debounce,
				  output [7:0] LEDOUT, LEDSEL,
                  output [2:0] in_1_led, in_2_led,
				  output done_top_led);

wire DONT_USE, clk_5KHz, man_clk;
wire [3:0] State, Total;
wire [7:0] State_LED, Total_LED;

assign in_1_led = in_1;
assign in_2_led = in_2;

	DP_CU D1(.go(Go_top), .op(Op_top), .in1(in_1), .in2(in_2), .clk(man_clk), .cs(State), .done(done_top_led),
			 .out(Total));

	bcd_to_7seg BCD1(.BCD(State), .s(State_LED));
	bcd_to_7seg BCD2(.BCD(Total), .s(Total_LED));

	button_debouncer BD1(.clk(clk_5KHz), .button(debounce), .debounced_button(man_clk));

	clk_gen CLK(.clk(clk_5KHz), .button(debounce), .debounced_button(man_clk));

	led_mux L1(.clk(clk_5KHz), .rst(rst), 
	           .LED0(State_LED), .LED1(vcc), .LED2(vcc), .LED3(vcc), 
	           .LED4(vcc), .LED5(vcc), .LED6(vcc), .LED7(Total_LED), 
	           .LEDSEL(LEDSEL), .LEDOUT(LEDOUT));

endmodule
