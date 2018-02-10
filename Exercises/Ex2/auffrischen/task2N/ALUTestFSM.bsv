package ALUTestFSM;

    import StmtFSM::*;
    import Vector::*;
/////////////////////////////////////////////////////
    typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits, FShow);
    typedef union tagged {UInt#(32) Unsigned; Int#(32) Signed;} SignedOrUnsigned deriving (Bits, Eq);
    typedef struct {
        SignedOrUnsigned    opA;
        SignedOrUnsigned    opB;
        AluOps              operator;
        SignedOrUnsigned    expectedResult;
    } TestData deriving (Eq, Bits);

////////////////////////////////////////////////////
    interface Power;
        method Action   setOperands(Int#(32) a, Int#(32) b);
        method Int#(32) getResult ();
    endinterface

    module mkPower(Power);
        Reg#(Int#(32))  opA     <- mkReg(0);
        Reg#(Int#(32))  opB     <- mkReg(0);
        Reg#(Int#(32))  result  <- mkReg(0);

        Reg#(Bool)  readyForCalc<- mkReg(False);
        Reg#(Bool)  validResult <- mkReg(False);

        rule calculate ( readyForCalc && opB > 0);
            result  <= result * opA;
            opB     <= opB - 1;
        endrule

        rule calcDone ( opB <= 0 && ! validResult);
            readyForCalc <= False;
            validResult  <= True;
        endrule

        method Action   setOperands(Int#(32) a, Int#(32) b) if ( !readyForCalc );
            opA     <= a;
            opB     <= b;
            result  <= 1;

            readyForCalc <= True;
            validResult  <= False;
        endmethod

        method Int#(32) getResult() if ( validResult );
            return result;
        endmethod

    endmodule

////////////////////////////////////////////////////
    interface ALU;
        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
        method ActionValue#(Int#(32)) getResult();
    endinterface

    module mkALU(ALU);
        Power                   pow     <- mkPower();

        Reg#(SignedOrUnsigned)  opA     <- mkReg(0);
        Reg#(SignedOrUnsigned)  opB     <- mkReg(0);
        Reg#(SignedOrUnsigned)  result  <- mkReg(0);
        Reg#(AluOps)            operation<- mkReg(Mul);

        Reg#(Bool)      readyForCalc    <- mkReg(False);
        Reg#(Bool)      validResult     <- mkReg(False);

        rule calculate (readyForCalc == True);
            SignedOrUnsigned    tmpResult = 0;
            case(operation) 
                Mul:    tmpResult = opA * opB;
                Div:    tmpResult = opA / opB;
                Add:    tmpResult = opA + opB;
                Sub:    tmpResult = opA - opB;
                And:    tmpResult = opA & opB;
                Or:     tmpResult = opA | opB;
                //Pow:    tmpResult = pow.getResult();
            endcase

            result <= tmpResult;
            readyForCalc <= False;
            validResult <= True;
        endrule

        method Action setupCalculationUnsigned(AluOps op, UInt#(32) a, UInt#(32) b);
            opA <= a;
            opB <= b;
            operation <= op;

            readyForCalc    <= True;
            validResult     <= False;
        endmethod

        method Action setupCalculationSigned(AluOps op, Int#(32) a, Int#(32) b);
            opA <= a;
            opB <= b;
            operation <= op;

            readyForCalc    <= True;
            validResult     <= False;
        endmethod

        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b) if(!readyForCalc);
            if (a matches tagged Unsigned .aVal && b matches tagged Unsigned .bVal)
                setupCalculationUnsigned(op, aVal, bVal);
            else if (a matches tagged Signed .aVal && b machtes tagged Signed .bVal);
                setupCalculationSigned(op, aVal, bVal);
            else
                $display("(%0d) operand-types must be the same");
        endmethod

        method ActionValue#(Int#(32)) getResult() if (validResult);
            validResult <= False;
            return result;
        endmethod

    endmodule

////////////////////////////////////////////////////
////////////////////////////////////////////////////
    module mkALUTestbench(Empty);
        ALU             dut     <- mkALU();
        Reg#(UInt#(12)) counter <- mkReg(0);
        Reg#(UInt#(12)) counterLimit <- mkReg( 6 );

        Vector#(6, TestData) testVector;
        testVector[0] = TestData{opA: 3, opB: 4, operator: Mul, expectedResult: 12};
        testVector[1] = TestData{opA: 12, opB: 4, operator: Div, expectedResult: 3};
        testVector[2] = TestData{opA: 3, opB: 4, operator: Add, expectedResult: 7};
        testVector[3] = TestData{opA: 7, opB: 4, operator: Sub, expectedResult: 3};
        testVector[4] = TestData{opA: 3, opB: 1, operator: And, expectedResult: 1};
        testVector[5] = TestData{opA: 3, opB: 1, operator: Or, expectedResult: 3};
        //testVector[6] = TestData{opA: 2, opB: 3, operator: Pow, expectedResult: 8};

        Stmt checkStmt = {
            seq
                action
                    let testData = testVector[counter];
                    dut.setupCalculation(testData.operator, testData.opA, testData.opB);
                endaction
                action
                    let testData = testVector[counter];
                    let result   <- dut.getResult();
                    let print = $format("Calculation: %d ", testData.opA) + fshow(testData.operator) + $format(" %d", testData.opB);
                    $display(print);
                    if( result == testData.expectedResult ) begin
                        $display("Test #%d: correct. Result: %d", counter, result);
                    end else begin
                        $display("Test #%d: incorrect. expectedResult: %d != result: %d", counter, testData.expectedResult, result);
                    end
                endaction
            endseq
        };
        FSM checkFSM    <- mkFSM(checkStmt);
        Stmt testStmt = {
            seq
                for( counter <= 0; counter < counterLimit; counter <= counter + 1) seq
                    checkFSM.start();
                    checkFSM.waitTillDone();    
                endseq
            endseq
        };
        mkAutoFSM( testStmt );
    endmodule

endpackage