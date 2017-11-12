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
        Reg#(Bool)      state1  <- mkReg(True);
        Reg#(Bool)      state2  <- mkReg(False);
        Reg#(Bool)      state3  <- mkReg(False);
        Reg#(Bool)      state4  <- mkReg(False);
        Reg#(Bool)      state5  <- mkReg(False);
        Reg#(Bool)      state6  <- mkReg(False);
        Reg#(Bool)      state7  <- mkReg(False);

        rule stateMult(state1);
            $display("Testing Multiplication:");
            dut.setupCalculation(Mul, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Mul, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state1 <= False;
            state2 <= True;
        endrule

        rule stateDiv(state2);
            $display("Testing Multiplication:");
            dut.setupCalculation(Div, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Div, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state2 <= False;
            state3 <= True;
        endrule

        rule stateAdd(state3);
            $display("Testing Multiplication:");
            dut.setupCalculation(Add, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Add, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state3 <= False;
            state4 <= True;
        endrule

        rule stateSub(state4);
            $display("Testing Multiplication:");
            dut.setupCalculation(Sub, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Sub, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state4 <= False;
            state5 <= True;
        endrule

        rule stateAnd(state5);
            $display("Testing Multiplication:");
            dut.setupCalculation(And, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(And, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state5 <= False;
            state6 <= True;
        endrule

        rule stateOr(state6);
            $display("Testing Multiplication:");
            dut.setupCalculation(Or, 5, 12);
            $display("5 * 12=%d", dut.getResult());
            dut.setupCalculation(Or, 5, -12);
            $display("5 * -12=%d", dut.getResult());
            state6 <= False;
            state7 <= True;
        endrule

        rule finishState(state7);
            $display("testbench finished");
            $finish();
        endrule
    endmodule
endpackage