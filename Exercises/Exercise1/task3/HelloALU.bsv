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
        HelloALU        dut        <- mkSimpleALU;
        Reg#(int))      state      <- mkReg(0);

        rule printState;
            $display("State: %d", state);
            state <= 1;
        endrule

        rule stateMult(state == 1);
            $display("Testing Multiplication:");
            dut.setupCalculation(Mul, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Mul, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateDiv(state == 2);
            $display("Testing Multiplication:");
            dut.setupCalculation(Div, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Div, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateAdd(state == 3);
            $display("Testing Multiplication:");
            dut.setupCalculation(Add, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Add, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateSub(state == 4);
            $display("Testing Multiplication:");
            dut.setupCalculation(Sub, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Sub, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateAnd(state == 5);
            $display("Testing Multiplication:");
            dut.setupCalculation(And, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(And, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule stateOr(state == 6);
            $display("Testing Multiplication:");
            dut.setupCalculation(Or, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Or, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            //state <= state + 1;
        endrule

        rule finishState(state == 7);
            $display("testbench finished");
            $finish();
        endrule

        method ActionValue#(int) getNextState;
            return state + 1;
        endmethod
    endmodule
endpackage