package HelloALU;
    typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits);

    interface Power;
        method Action   setOperands (Int#(32) a, Int#(32) b);
        method Int#(32) getResult;
    endinterface
    module mkPower(Power);
        Reg#(Int#(32))  operand1    <- mkRegU;
        Reg#(Int#(32))  operand2    <- mkRegU;
        Reg#(Int#(32))  result      <- mkRegU;

        Reg#(Bool)      readyForCalc<- mkReg(False);
        Reg#(Bool)      validResult <- mkReg(False);

        method Action   setOperands (Int#(32) a, Int#(32) b);
            operand1 <= a;
            operand2 <= b;
            result   <= 1;
            readyForCalc <= True;
        endmodule

        rule calculate (readyForCalc == True);
            if (operand2 == 0) begin
                validResult <= True;
                readyForCalc<= False; 
            end
            else begin
                result <= result * operand1;
                operand2 <= operand2 - 1;
            end
        endrule

        method Int#(32) getResult if (validResult);
            validResult <= False;
            return result;
        endmodule
    endmodule

    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))   getResult();
    endinterface
    module mkHelloALU(HelloALU);
        Power           pow      <- mkPower();
        Reg#(AluOps)    operation<- mkRegU;
        Reg#(Int#(32))  op1      <- mkRegU;
        Reg#(Int#(32))  op2      <- mkRegU;
        Reg#(Int#(32))  result   <- mkRegU;
        
        Reg#(Bool)      readyForCalc    <- mkReg(False);
        Reg#(Bool)      validResult     <- mkReg(False);

        rule calculate (readyForCalc);
            Int#(32)    tmpResult = 0;
            case(operation)
                Mul:    tmpResult = op1 * op2;
                Div:    tmpResult = op1 / op2;
                Add:    tmpResult = op1 + op2;
                Sub:    tmpResult = op1 - op2;
                And:    tmpResult = op1 & op2;
                Or:     tmpResult = op1 | op2;
                Pow:    tmpResult = pow.getResult();
            endcase

            result <= tmpResult;
            readyForCalc <= False;
            validResult  <= True;
        endrule

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            operation   <= op;
            op1         <= a;
            op2         <= b;
            readyForCalc <= True;
            if (op == Pow)
                pow.setOperands(a, b);
        endmethod

        method ActionValue#(Int#(32)) getResult() if(validResult);
            validResult <= False;
            return result;
        endmethod
    endmodule

    module mkALUTestbench(Empty);
        HelloALU dut    <- mkHelloALU();
        Reg#(UInt#(32)) state <- mkReg(0);

    endmodule
endpackage