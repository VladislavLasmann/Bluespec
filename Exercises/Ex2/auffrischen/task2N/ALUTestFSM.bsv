package ALUTestFSM;

    import StmtFSM::*;
    import Vector::*;
/////////////////////////////////////////////////////
    typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits, FShow);
    typedef union tagged {UInt#(32) Unsigned; Int#(32) Signed;} SignedOrUnsigned deriving (Bits, Eq);
    typedef struct {
        Int#(32)    opA;
        Int#(32)    opB;
        AluOps      operator;
        Int#(32)    expectedResult;
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
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32)) getResult();
    endinterface

    module mkALU(ALU);
        Power           pow     <- mkPower();

        Reg#(Int#(32))  opA     <- mkReg(0);
        Reg#(Int#(32))  opB     <- mkReg(0);
        Reg#(Int#(32))  result  <- mkReg(0);
        Reg#(AluOps)    operation <- mkReg(Mul);

        Reg#(Bool)      readyForCalc    <- mkReg(False);
        Reg#(Bool)      validResult     <- mkReg(False);

        rule calculate (readyForCalc == True);
            Int#(32)    tmpResult = 0;
            case(operation) 
                Mul:    tmpResult = opA * opB;
                Div:    tmpResult = opA / opB;
                Add:    tmpResult = opA + opB;
                Sub:    tmpResult = opA - opB;
                And:    tmpResult = opA & opB;
                Or:     tmpResult = opA | opB;
                Pow:    tmpResult = pow.getResult();
            endcase

            result <= tmpResult;
            readyForCalc <= False;
            validResult <= True;
        endrule

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if(!readyForCalc);
            opA <= a;
            opB <= b;
            operation <= op;
            result <= 0;

            readyForCalc    <= True;
            validResult     <= False;

            pow.setOperands(a, b);
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
        Reg#(UInt#(12)) counterLimit <- mkReg( 7 );

        Vector#(6, TestData) testVector;
        testVector[0] = TestData{opA: 3, opB: 4, operator: Mul, expectedResult: 12};
        testVector[1] = TestData{opA: 12, opB: 4, operator: Div, expectedResult: 3};
        testVector[2] = TestData{opA: 3, opB: 4, operator: Add, expectedResult: 7};
        testVector[3] = TestData{opA: 7, opB: 4, operator: Sub, expectedResult: 3};
        testVector[4] = TestData{opA: 3, opB: 1, operator: And, expectedResult: 1};
        testVector[5] = TestData{opA: 3, opB: 1, operator: Or, expectedResult: 3};
        testVector[6] = TestData{opA: 2, opB: 3, operator: Pow, expectedResult: 8};



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