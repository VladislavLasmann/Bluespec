package HelloALU;

typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);

    interface HelloALU;
        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))   getResult();
    endinterface;

    module mkSimpleALU(HelloALU);
        Reg#(AluOps)    operation       <- mkRegU;
        Reg#(Bool)      gotNewOperation <- mkReg(False);

        Reg#(Bool)      resultCalculated<- mkReg(False);
        Reg#(Int#(32))  firstOperand    <- mkReg(0);
        Reg#(Int#(32))  secondOperand   <- mkReg(0);
        Reg#(Int#(32))  result          <- mkReg(0);

        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if( !resultCalculated ) ;
            firstOperand    <= a;
            secondOperand   <= b;
            operation       <= op;
            gotNewOperation <= True;
        endmethod

        method ActionValue#(Int#(32)) getResult() if (resultCalculated);
            return result;
        endmethod

        rule calculate ( gotNewOperation );
            Int#(32) ruleResult = 0;
            case(operation)
                Mult:   ruleResult = firstOperand * secondOperand;
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
    endmodule

    module mkTestbench(Empty);
        HelloALU        dut             <- mkSimpleALU;

        Reg#(Int#(32))  firstOperand    <- mkReg(0);
        Reg#(Int#(32))  secondOperand   <- mkReg(0);
        Reg#(Int#(32))  result          <- mkReg(0);

        Reg#(UInt#(3))  state           <- mkReg(0);
        Reg#(Bool)      flush           <- mkReg(False);

        rule flushValues (flush);
            firstOperand    <= 0;
            secondOperand   <= 0;
            result          <= 0;
            flush           <= False;
        endrule

        rule state0_Mult (!flush && (state == 0) );
            
            flush           <= True;
            state           <= state + 1;
        endrule

        rule finish (!flush && (state == 1) );
            $display("testbench finished");
            $finish();
        endrule
    endmodule
endpackage;