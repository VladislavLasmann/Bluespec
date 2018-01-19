package FSM;
    import StmtFSM::*;
    import Vector::*;

    typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);
    typedef struct{
        Int#(32)    opA;
        Int#(32)    opB;
        AluOps      operator;
        Int#(32)    expectedResult;
    } TestData deriving (Eq, Bits);

    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue #(Int#(32)) getResult();
    endinterface

    module mkHelloALU(HelloALU);
        Reg #(Int#(32)) number1 <- mkReg(0);
        Reg #(Int#(32)) number2 <- mkReg(0);
        Reg #(Int#(32)) result  <- mkReg(0);
        Reg #(AluOps)   operation <- mkRegU;

        Reg #(Bool)     readyForCalculation<- mkReg(False);
        Reg #(Bool)     validResult <- mkReg(False);

        rule calculate (readyForCalculation);
            Int#(32) tmpResult = 0;
            case (operation)
                Mul : tmpResult = number1 * number2;
                Div : tmpResult = number1 / number2;
                Add : tmpResult = number1 + number2;
                Sub : tmpResult = number1 - number2;
                And : tmpResult = number1 & number2;
                Or  : tmpResult = number1 | number2;
            endcase;
            vaidResult <= True;
            readyForCalculation <= False;
            result <= tmpResult;
        endrule: calculate

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            number1 <= a;
            number2 <= b;
            operation <= op;
            readyForCalculation <= True;
        endmethod: setupCalculation

        method ActionValue #(Int#(32)) getResult();
            validResult <= False;
            return result;
        endmethod: getResult

    endmodule: mkHelloALU;

    module mkSecondFSM(Empty);
        Reg#(Bool)      seq1Val <- mkReg(False);

        Stmt fsm_Stmt = {
            par
                seq
                    $display("[1] (%0d) Hello World", $time);
                    delay(100);
                    seq1Val <= True;
                    $display("[1] (%0d) done", $time);
                endseq

                seq
                    repeat (10) 
                        $display("[2] (%0d) Hello World", $time);                    
                    await(seq1Val);
                    $display("[1] (%0d) done", $time);
                endseq

            endpar
        };
        mkAutoFSM(fsm_Stmt);
    endmodule: mkSecondFSM

    module mkThirdFSM(Empty);
        Reg#(UInt#(12))  counter <- mkReg(0);
        PulseWire        pw <- mkPulseWire();
        Reg#(UInt#(12))  i <- mkReg(0);

        rule count (counter < 99 );
            counter <= counter + 1;
        endrule 

        rule resetCount (counter == 99);
            counter <= 0;
            pw.send();
        endrule

        Stmt thirdStmt = {
            seq 
                for( i <= 0; i < 20; i <= i + 1)
                    seq
                        $display("(%0d) Iteration %d", $time, i);
                    endseq
                $finish();
            endseq
        };

        FSM myFSM <- mkFSMWithPred(thirdStmt, pw);
        rule startFSM ( myFSM.done() );
            myFSM.start();
        endrule

    endmodule: mkThirdFSM

    module testBenchFSM(Empty);
        Reg #(UInt#(32)) indexCounter <- mkReg(0);
        Vector#(18, TestData) testVector;
        HelloALU alu <- mkHelloALU;
        testVector[0] = TestData{opA:-3 , opB:5 , operator: Mul, expectedResult:-15 };
        testVector[1] = TestData{opA:0 , opB:5 , operator: Mul, expectedResult:0 };
        testVector[1] = TestData{opA:3 , opB:5 , operator: Mul, expectedResult:15 };
        testVector[3] = TestData{opA:-15 , opB:-3 , operator: Div, expectedResult:5 };
        testVector[4] = TestData{opA:0 , opB:3 , operator: Div, expectedResult:0 };
        testVector[5] = TestData{opA:15 , opB:3, operator: Div, expectedResult:5 };
        testVector[6] = TestData{opA:-3 , opB:-5 , operator: Add, expectedResult:-8 };
        testVector[7] = TestData{opA:0 , opB:5 , operator: Add, expectedResult:5 };
        testVector[8] = TestData{opA:3 , opB:-3 , operator: Add, expectedResult:0 };
        testVector[9] = TestData{opA:-3 , opB:-3 , operator: Sub, expectedResult:0 };
        testVector[10] = TestData{opA:0 , opB:3 , operator: Sub, expectedResult:-3 };
        testVector[11] = TestData{opA:3 , opB:3 , operator: Sub, expectedResult:6 };
        testVector[12] = TestData{opA:0 , opB:1 , operator: And, expectedResult:0 };
        testVector[13] = TestData{opA:3 , opB:3 , operator: And, expectedResult:3 };
        testVector[14] = TestData{opA:4 , opB:4 , operator: And, expectedResult:4 };
        testVector[15] = TestData{opA:1 , opB:0 , operator: Or, expectedResult:1 };
        testVector[16] = TestData{opA:4 , opB:3 , operator: Or, expectedResult:7 };
        testVector[17] = TestData{opA:0 , opB:0 , operator: Or, expectedResult:0 };

        Stmt checkStmt = {
            seq
                action
                    let currentData = myVector[indexCounter];
                    alu.setupCalculation(currentData.operator, currentData.opA, currentData.opB);
                endaction
                action
                    let currentData = myVector[indexCounter];
                    let result <- alu.getResult();
                    let print = $format("Calculation: %d", currentData.opA) +
                                fshow(currentData.operator) + $format("%d", currentData.opB);
                    $display(print);
                    if(result == currentData.expectedResult) begin
                        $display("Result correct: %d", result);
                    end else begin
                        $display("Result incorrect: %d != %d", result, currentData.expectedResult);
                    end
                endaction
            endseq
        };

        FSM checkFSM <- mkFSM(checkStmt);
        Stmt mainFSM = {
            seq
                for(indexCounter <= 0; indexCounter < 18; indexCounter <= indexCounter + 1)
                seq
                    checkFSM.start();
                    checkFSM.waitTillDone();
                endseq
            endseq
        }
        mkAutoFSM(mainFSM);

    endmodule: testBenchFSM

endpackage: FSM