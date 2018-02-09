package HelloALU;
    typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits);
    
    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))   getResult();
    endinterface

    module mkHelloALU(HelloALU);
        Reg#(AluOps)    operation<- mkRegU;
        Reg#(Int#(32))  op1      <- mkRegU;
        Reg#(Int#(32))  op2      <- mkRegU;
        Reg#(Int#(32))  result   <- mkRegU;
        
        Reg#(Bool)      readyForCalc    <- mkReg(False);
        Reg#(Bool)      validResult     <- mkReg(False);

        rule calculate (readyForCalc);
            Int#(32)    tmpResult = 0;
            case(operation);
                Mul:    tmpResult = op1 * op2;
                Div:    tmpResult = op1 / op2;
                Add:    tmpResult = op1 + op2;
                Sub:    tmpResult = op1 - op2;
                And:    tmpResult = op1 & op2;
                Or:     tmpResult = op1 | op2;
                Pow:    tmpResult = calculatePow(op1, op2);
            endcase;

            result <= tmpResult;
            readyForCalc <= False;
            validResult  <= True;
        endrule

        method #(Int#(32)) calculatePow(Int#(32) a, Int#(32) b);
            Int#(32)    tmpResult = a;

            for( int i = 0; i < b; i = i + 1)
                tmpResult = tmpResult * a;

            return tmpResult;
        endmethod

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            operation   <= op;
            op1         <= a;
            op2         <= b;
            readyForCalc <= True;
        endmethod

        method ActionValue#(Int#(32)) getResult() if(validResult);
            return result;
            validResult <= False;
        endmethod
    endmodule



    endmodule mkALUTestbench(Empty);
        HelloALU dut    <- mkHelloALU();
        Reg#(UInt#(32)) state <- mkReg(0);

    endmodule
endpackage