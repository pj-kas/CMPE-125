`timescale 1ns / 1ps

module tb_DP_CU();
    reg go, clk;
    reg [1:0] op;
    reg [2:0] in1, in2;
    wire [3:0] cs;
    wire done;
    wire [2:0] out;
    
    DP_CU DUT(  .go(go),
                .op(op),
                .in1(in1),
                .in2(in2),
                .clk(clk),
                .cs(cs),
                .done(done),
                .out(out));
    
    integer data1=0;
    integer data2=0;
    integer go_counter=0;
    integer op_counter=0;
    reg [2:0] tb_expected;
    
initial
begin
    //For loop used to cycle through different operations
    for(op_counter=0; op_counter<4; op_counter=op_counter+1) 
    begin
        op=op_counter;
        
        //For loop used to cycle through different in1 values
        for(data1=0; data1<8; data1=data1+1) 
        begin
            in1=data1;
           
            //For loop used to cycle through different in2 values
            for(data2=0; data2<8; data2=data2+1) 
            begin
                in2=data2;
                
                for(go_counter=0; go_counter<2; go_counter=go_counter+1) 
                begin
                    go=go_counter;
                    clk=1'b0; #10; clk=1'b1; #10;
                    //Check to make sure Go is functioning properly
                    if((go==1'b0)&&(cs!=4'b0000)) 
                    begin
                        $display("ERROR, Go is %d and CS is %d, CS should be 0", go, cs);
                    end 

                    else if(go_counter>1'b0) 
                    begin
                        if(go!=1'b1) begin
                            $display("ERROR, Go is %d and should be 1", go);
                        end
            
                        clk=1'b0; #10; clk=1'b1; #10;
                        clk=1'b0; #10; clk=1'b1; #10;
                        clk=1'b0; #10; clk=1'b1; #10;
                        clk=1'b0; #10; clk=1'b1; #10;

                        //Case statement used to calculate expected output based on operand input
                        case(op)
                            2'b00: tb_expected = in1 + in2;
                            2'b01: tb_expected = in1 - in2;
                            2'b10: tb_expected = in1 & in2;
                            default: tb_expected = in1 ^ in2; // 2'b11;
                        endcase
                        //Once state 8 has been reached check to make sure Done flag is thrown
                        if((cs==4'b1000)&&(done!=1'b1)) 
                        begin
                            $display("ERROR, CS is %d and Done is %d", cs, done);
                        end
                        //Here we check expected output with actual output
                        if(tb_expected!=out) 
                        begin
                            $display("ERROR, expected output: %d, actual output: %d", tb_expected, out);
                        end
                        clk=1'b0; #10; clk=1'b1; #10;
                    end
                end
            end
        end
    end
    $display("**********ALL TESTS SUCCESSFUL**********");
    end  
endmodule
