`timescale 1ns / 1ps

module CU (input [1:0] Op,
           input Go, clk,
           output reg [13:0] ctrl_sig, // S1, WA, WE, RAA, REA, RAB, REB, C, S2
           output reg [3:0] State,
           output reg Done);


parameter S0 = 4'b0000, // next state binary values
          S1 = 4'b0001, // load R1
          S2 = 4'b0010, // load R2
          S3 = 4'b0011, // wait for opcode
          S4 = 4'b0100, // R3 = R1 + R2
          S5 = 4'b0101, // R3 = R1 - R2
          S6 = 4'b0110, // R3 = R1 & R2
          S7 = 4'b0111, // R3 = R1 ^ R2
          S8 = 4'b1000, // R3 output through ALU to out
          IDLE        =	14'b01_00_0_00_0_00_0_00_0, //ctrl outputs for datapath module
          LOAD_R1     = 14'b11_01_1_00_0_00_0_00_0,
          LOAD_R2 	  = 14'b10_10_1_00_0_00_0_00_0,
          WAIT        = 14'b01_00_0_00_0_00_0_00_0,
          LOAD_R3_ADD = 14'b00_11_1_01_1_10_1_00_0,
          LOAD_R3_SUB = 14'b00_11_1_01_1_10_1_01_0,
          LOAD_R3_AND = 14'b00_11_1_01_1_10_1_10_0,
          LOAD_R3_XOR = 14'b00_11_1_01_1_10_1_11_0,
          R3_OUTPUT   = 14'b01_00_0_11_1_11_1_10_1; // AND R3 with itself and output

reg [3:0] CS = S0;
reg [3:0] NS;

always @(posedge clk) // current state to next state block
begin
    CS <= NS; 
end

always @ (*) // Next state logic (CS, Go, Op)
begin
    case(CS)
        S0: begin // idle at state 0 until go is received
                if (!Go) NS = S0;
                else NS = S1;
            end
        S1: NS = S2; // no input needed for states 1 and 2
        S2: NS = S3;
        S3: begin // check for opcode to identify ALU operation
                case(Op)
                    0: NS = S4;
                    1: NS = S5;
                    2: NS = S6;
                    3: NS = S7;
                endcase
            end
        S4: NS = S8; // all cases here lead to state 8
        S5: NS = S8;
        S6: NS = S8;
        S7: NS = S8;   
        S8: NS = S0; // state returns to state 0
    endcase
end

always @ (*) // output logic at each state
begin
Done = 1'b0;
    case(CS)
        S0: begin ctrl_sig = IDLE;    State = CS; end
        S1: begin ctrl_sig = LOAD_R1; State = CS; end
        S2: begin ctrl_sig = LOAD_R2; State = CS; end
        S3: begin ctrl_sig = WAIT; State = CS; end
        S4: begin ctrl_sig = LOAD_R3_ADD; State = CS; end
        S5: begin ctrl_sig = LOAD_R3_SUB; State = CS; end
        S6: begin ctrl_sig = LOAD_R3_AND; State = CS; end
        S7: begin ctrl_sig = LOAD_R3_XOR; State = CS; end
        S8: begin ctrl_sig = R3_OUTPUT; Done = 1; State = CS; end
    endcase
end

endmodule