package ALUTestFSM;

    import StmtFSM::*;
    import Vector::*;
    typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits, FShow);
    typedef struct {
        Int#(32)    opA;
        Int#(32)    opB;
        AluOps      operator;
        Int#(32)    expectedResult;
    } TestData deriving (Eq, Bits);

    interface ALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32)) getResult();
    endinterface

    module mkALU(ALU);
        Reg#(Int#(32))  opA     <- mkRegU();
        Reg#(Int#(32))  opB     <- mkRegU();
        Reg#(Int#(32))  result  <- mkRegU();
        Reg#(AluOps)    operation <- mkRegU();

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
            endcase

            result <= tmpResult;
            readyForCalc <= False;
            validResult <= True;
        endrule

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            opA <= a;
            opB <= b;
            operation <= op;
            result <= 0;

            readyForCalc    <= True;
            validResult     <= False;
        endmethod

        method ActionValue#(Int#(32)) getResult();
            return operation;
        endmethod

    endmodule

    module mkALUTestbench(Empty);
        ALU             dut     <- mkALU();
        Reg#(UInt#(12)) counter <- mkReg(0);

        Vector#(6, TestData) testVector;
        testVector[0] = TestData{opA: 3, opB: 4, operator: Mul, expectedResult: 12};
        testVector[1] = TestData{opA: 12, opB: 4, operator: Div, expectedResult: 3};
        testVector[2] = TestData{opA: 3, opB: 4, operator: Add, expectedResult: 7};
        testVector[3] = TestData{opA: 7, opB: 4, operator: Sub, expectedResult: 3};
        testVector[4] = TestData{opA: 3, opB: 1, operator: And, expectedResult: 1};
        testVector[5] = TestData{opA: 3, opB: 1, operator: Or, expectedResult: 3};


        Stmt checkStmt = {
            seq
                action
                    let testData = testVector[counter];
                    dut.setupCalculation(testData.operator, testData.opA, testData.opB);
                endaction
                action
                    let testData = testVector[counter];
                    let result   <- uut.getResult();
                    let print = $format("Calculation: %d ", testData.opA) + fshow(testData.operator) + $format("$d", testData.opB);
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
                for( counter <= 0; counter < 6; counter <= counter + 1) seq
                    checkFSM.start();
                    checkFSM.waitTillDone();    
                endseq
            endseq
        };
        mkAutoFSM( testStmt );
    endmodule

endpackage