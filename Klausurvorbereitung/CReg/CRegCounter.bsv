package CRegCounter;
    import StmtFSM :: *;

    interface SimpleCounter;
        method ActionValue #(UInt#(32)) incrdecr (#UInt#(32) incrval, UInt#(32) decrval);
    endinterface

    module mkSimpleCounter(SimpleCounter);
        Reg #(UInt#(32)) counterVal <- mkReg(0);
        Reg #(UInt#(32)) ctrVal[2]  <- mkCReg(2, 0);

        method ActionValue #(UInt#(32)) incrdecr (#UInt#(32) incrval, #UInt#(32) decrval);
            counterVal  <= counterVal + ctrVal[0] - ctrVal[1];
            ctrVal[0]   <= incrval;
            ctrVal[1]   <= decrval;

            return counterVal;
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