package HelloALU;

typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);

    interface HelloALU;
        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))   getResult();
    endinterface

    module mkSimpleALU(HelloALU);
        Reg#(AluOps)    operation       <- mkRegU;
        Reg#(Bool)      gotNewOperation <- mkReg(False);

        Reg#(Bool)      resultCalculated<- mkReg(False);
        Reg#(Int#(32))  firstOperand    <- mkReg(0);
        Reg#(Int#(32))  secondOperand   <- mkReg(0);
        Reg#(Int#(32))  result          <- mkReg(0);

        rule calculate ( gotNewOperation );
            Int#(32) ruleResult = 0;
            case(operation)
                Mul:    ruleResult = firstOperand * secondOperand;
                Div:    ruleResult = firstOperand / secondOperand;
                Add:    ruleResult = firstOperand + secondOperand;
                Sub:    ruleResult = firstOperand - secondOperand;
                And:    ruleResult = firstOperand & secondOperand;
                Or:     ruleResult = firstOperand | secondOperand;
            endcase
            result          <= ruleResult;
            gotNewOperation <= False;
            resultCalculated<= True;
        endrule

        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if( !resultCalculated ) ;
            firstOperand    <= a;
            secondOperand   <= b;
            operation       <= op;
            gotNewOperation <= True;
        endmethod

        method ActionValue#(Int#(32)) getResult() if (resultCalculated);
            return result;
        endmethod
    endmodule

    module mkTestbench(Empty);
        HelloALU        dut     <- mkSimpleALU;
        Reg#(UInt#(8))  state   <- mkReg(1);

        rule stateMult;
            if (state == 'h1) begin
                $display("Testing Multiplication:");
                dut.setupCalculation(Mul, 5, 12);
                $display("5 * 12=%d", dut.getResult());
                dut.setupCalculation(Mul, 5, -12);
                $display("5 * -12=%d", dut.getResult());
                state <= state + 1;
            end
        endrule

        rule stateDiv(state == 'h2);
            $display("Testing Multiplication:");
            dut.setupCalculation(Div, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Div, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateAdd(state == 'h3);
            $display("Testing Multiplication:");
            dut.setupCalculation(Add, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Add, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateSub(state == 'h4);
            $display("Testing Multiplication:");
            dut.setupCalculation(Sub, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Sub, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateAnd(state == 'h5);
            $display("Testing Multiplication:");
            dut.setupCalculation(And, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(And, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateOr(state == 'h6);
            $display("Testing Multiplication:");
            dut.setupCalculation(Or, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Or, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule finishState(state == 'h7);
            $display("testbench finished");
            $finish();
        endrule
    endmodule
endpackage