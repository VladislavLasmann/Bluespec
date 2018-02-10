package Counter;
    import StmtFSM::*;
    import Vector::*;

/////////////////////////////////////////////////////////////////////////////
    typedef union tagged {
        void Invalid;
        data_t Valid;
    } Maybe #(type data_t) deriving (Eq, Bits);

    typedef struct {
        UInt#(32) incr;
        UInt#(32) decr;
        UInt#(32) expectedCount;
    } TestData deriving (Eq, Bits);
/////////////////////////////////////////////////////////////////////////////
    interface SimpleCounter;
        method Action incr(UInt#(32) v);
        method Action decr(UInt#(32) v);
        method UInt#(32) counterValue();
    endinterface

    module mkSimpleCounter(SimpleCounter);
        Reg#(UInt#(32))     counter    <- mkReg(0);
        RWire#(UInt#(32))   incrWire    <- mkRWire();
        RWire#(UInt#(32))   decrWire   <- mkRWire();

        rule count;
            Maybe#(UInt#(32))   incrMaybe = incrWire.wget();
            Maybe#(UInt#(32))   decrMaybe = decrWire.wget();

            let incrValue   = fromMaybe(0, incrMaybe);
            let decrValue   = fromMaybe(0, decrMaybe);
            counter         <= counter + incrValue + decrValue;
        endrule

        method Action incr(UInt#(32) v);
            incrWire.wset( v );
        endmethod
        method Action decr(UInt#(32) v);
            incrWire.wset( v );
        endmethod
        method UInt#(32) counterValue();
            return counter;
        endmethod
    endmodule
/////////////////////////////////////////////////////////////////////////////

    module mkTestbench(Empty);
        SimpleCounter   dut     <- mkSimpleCounter();


        let maxElements = 4;
        Reg#(UInt#(32)) i       <- mkReg(0);
        Reg#(UInt#(32)) pntr    <- mkReg(0);

        Vector#(maxElements, TestData) testVector;
        testVector[0]=TestData {incr: 5, decr: 3, expectedCount: 2};
        testVector[1]=TestData {incr: 3, decr: 5, expectedCount: 0};
        testVector[2]=TestData {incr: 7, decr: 7, expectedCount: 0};
        testVector[3]=TestData {incr: 4, decr: 3, expectedCount: 1};

        Stmt testStmt = {
            seq
                action
                    let testData = testVector[pntr];
                    dut.incr(testData.incr);
                    dut.decr(testData.decr);
                endaction
                action
                    let testData = testVector[pntr];
                    let result  <- dut.counterValue;
                    let print = $format("incr: %d, decr: %d", testData.incr, testData.decr);
                    $display(print);
                    if( result == testData.expectedCount )
                        $display("correct result: %d", result);
                    else
                        $display("incorrect result: result: %d != expectedResult: %d", result, testData.expectedCount);
                endaction
                pntr <= pntr + 1;
            endseq
        };
        FSM testFSM <- mkFSM( testStmt );
        Stmt runFSM = {
            seq
                for(i <= 0; i < maxElements; i <= i + 1) seq
                    testFSM.start();
                    testFSM.waitTillDone();
                endseq
            endseq
        };
        mkAutoFSM(runFSM);
    endmodule
endpackage