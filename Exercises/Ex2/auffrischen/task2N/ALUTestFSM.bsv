package ALUTestFSM;

    import StmtFSM::*;
    import Vector::*;
/////////////////////////////////////////////////////
    typedef enum{Mul, Div, Add, Sub, And, Or, Pow} AluOps deriving (Eq, Bits, FShow);
    typedef union tagged {Int#(32) Signed; UInt#(32) Unsigned} SignedOrUnsigned deriving (Bits, Eq);
    typedef struct {
        SignedOrUnsigned    opA;
        SignedOrUnsigned    opB;
        AluOps              operator;
        SignedOrUnsigned    expectedResult;
    } TestData deriving (Eq, Bits);

////////////////////////////////////////////////////
    interface Power;
        method Action   setOperands(SignedOrUnsigned a, SignedOrUnsigned b);
        method SignedOrUnsigned getResult ();
    endinterface

    module mkPower(Power);
        Reg#(SignedOrUnsigned)  opA     <- mkReg(tagged Signed 0);
        Reg#(SignedOrUnsigned)  opB     <- mkReg(tagged Signed 0);
        Reg#(SignedOrUnsigned)  result  <- mkReg(tagged Signed 0);

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

        method Action   setOperands(SignedOrUnsigned a, SignedOrUnsigned b) if ( !readyForCalc );
            opA     <= a;
            opB     <= b;
            if( a matches tagged Signed .aVal && b matches tagges Signed .bval)
                result  <= tagged Signed 1;
            else
                result  <= tagged Unsigned 1;

            readyForCalc <= True;
            validResult  <= False;
        endmethod

        method SignedOrUnsigned getResult() if ( validResult );
            return result;
        endmethod

    endmodule

////////////////////////////////////////////////////
    interface ALU;
        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
        method ActionValue#(SignedOrUnsigned) getResult();
    endinterface

    module mkALU(ALU);
        Power                   pow     <- mkPower();

        Reg#(SignedOrUnsigned)  opA     <- mkReg(tagged Signed 0);
        Reg#(SignedOrUnsigned)  opB     <- mkReg(tagged Signed 0);
        Reg#(SignedOrUnsigned)  result  <- mkReg(tagged Signed 0);
        Reg#(AluOps)            operation<- mkReg(Mul);

        Reg#(Bool)      readyForCalc    <- mkReg(False);
        Reg#(Bool)      validResult     <- mkReg(False);


        rule calculateSigned ( readyForCalc &&& opA matches tagged Signed .aVal &&& opB matches tagged Signed .bVal);
            Int#(32)    tmpResult = 0;
            case(operation) 
                Mul:    tmpResult = aVal * bVal;
                Div:    tmpResult = aVal / bVal;
                Add:    tmpResult = aVal + bVal;
                Sub:    tmpResult = aVal - bVal;
                And:    tmpResult = aVal & bVal;
                Or:     tmpResult = aVal | bVal;
                Pow:    tmpResult = pow.getResult();
            endcase

            result <= tagged Signed tmpResult;
            readyForCalc <= False;
            validResult <= True;
        endrule

        rule calculateUnsigned ( readyForCalc &&& opA matches tagged Unsigned .aVal &&& opB matches tagged Unsigned .bVal);
            UInt#(32)   tmpResult = 0;
            case(operation) 
                Mul:    tmpResult = aVal * bVal;
                Div:    tmpResult = aVal / bVal;
                Add:    tmpResult = aVal + bVal;
                Sub:    tmpResult = aVal - bVal;
                And:    tmpResult = aVal & bVal;
                Or:     tmpResult = aVal | bVal;
                Pow:    tmpResult = pow.getResult();
            endcase

            result <= tagged Unsigned tmpResult;
            readyForCalc <= False;
            validResult <= True;
        endrule

        /*
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
        */

        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b) if(!readyForCalc);
            opA <= a;
            opB <= b;
            operation <= op;

            readyForCalc    <= True;
            validResult     <= False;
            pow.setOperands(a, b);
        endmethod

        method ActionValue#(SignedOrUnsigned) getResult() if (validResult);
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

        Vector#(7, TestData) testVector;
        testVector[0] = TestData{opA: tagged Signed 3, opB: tagged Signed 4, operator: Mul, expectedResult: tagged Signed 12};
        testVector[1] = TestData{opA: tagged Signed 12, opB: tagged Signed 4, operator: Div, expectedResult: tagged Signed 3};
        testVector[2] = TestData{opA: tagged Signed 3, opB: tagged Signed 4, operator: Add, expectedResult: tagged Signed 7};
        testVector[3] = TestData{opA: tagged Unsigned 7, opB: tagged Unsigned 4, operator: Sub, expectedResult: tagged Unsigned 3};
        testVector[4] = TestData{opA: tagged Unsigned 3, opB: tagged Unsigned 1, operator: And, expectedResult: tagged Unsigned 1};
        testVector[5] = TestData{opA: tagged Unsigned 3, opB: tagged Unsigned 1, operator: Or, expectedResult: tagged Unsigned 3};
        testVector[6] = TestData{opA: tagged Signed 2, opB: tagged Signed 3, operator: Pow, expectedResult: tagged Signed 8};

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