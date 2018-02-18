package CRegCounter;
    import StmtFSM :: *;

    interface SimpleCounter;
        method ActionValue #(UInt#(32)) incrdecr (UInt#(32) incrval, UInt#(32) decrval);
    endinterface

    module mkSimpleCounter(SimpleCounter);
        Reg #(UInt#(32)) ctrVal[2]  <- mkCReg(2, 0);

        method ActionValue #(UInt#(32)) incrdecr (UInt#(32) incrval, UInt#(32) decrval);
            let ctrVal0 = ctrVal[0];
            ctrVal[0]   <= ctrVal0 + incrval;
            let ctrVal1 = ctrVal[1];
            ctrVal[1]   <= ctrVal1 - decrval;

            return ctrVal[1];
        endmethod

    endmodule

    module mkTestbench(Empty);
        SimpleCounter counter       <- mkSimpleCounter();

        Stmt testFSM = {
            seq
                $display("Setting: incr=%d, decr=%d, oldVal=%d", 3, 2, counter.incrdecr(3, 2) );
                $display("Setting: incr=%d, decr=%d, oldVal=%d", 1, 0, counter.incrdecr(1, 0) );
                $display("Setting: incr=%d, decr=%d, oldVal=%d", 5, 5, counter.incrdecr(5, 5) );
                $display("Setting: incr=%d, decr=%d, oldVal=%d", 5, 5, counter.incrdecr(5, 5) );
            endseq
        };

        mkAutoFSM(testFSM);
    endmodule

endpackage