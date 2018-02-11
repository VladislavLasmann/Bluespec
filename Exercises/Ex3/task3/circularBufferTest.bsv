package circularBufferTest;
    import BlueCheck::*;
    import Vector::*;

    module mkCircularBuffer(FIFO);
        // Pointer for indizes. Max Bit size: 4, because max index is 15
        // Overflow desired!
        Reg#(UInt#(4))  readPntr    <- mkReg(0);
        Reg#(UInt#(4))  writePntr   <- mkReg(0);
        // Circulat Buffer:
        Vector#(16, Reg#(Int#(16))) buffer  <- replicateM(mkRegU);

        method Action put(Int#(16) e) if ((writePntr + 1) != readPntr);
            buffer[writePntr] <= e;
            writePntr <= writePntr + 1;
        endmethod

        method ActionValue#(Int#(16)) get() if (readPntr != dataPntr);
            readPntr <= readPntr + 1;
            return buffer[readPntr];
        endmethod
    endmodule

    module [BlueCheck] checkStack ();
        /* Specification instance */
        Stack#(8, Bit#(4)) spec <- mkStackSpec();

        /* Implementation instance */
        Stack#(8, Bit#(4))  imp <- mkBRAMStack();

        equiv("pop"     , spec.pop,     imp.pop);
        equiv("push"    , spec.push,    imp.push);
        equiv("isEmpty" , spec.isEmpty, imp.isEmpty);
        equiv("top"     , spec.top,     imp.top);
    endmodule

    module [BlueCheck] mkFIFOSpec();
        FIFO#(Int#(16)) spec    <- mkSizedFIFO(16);
        FIFO          impl      <- mkCircularBuffer();

        function ActionValue #(Int#(16)) pop(FIFO#(Int#(16)) e);
            actionvalue
                e.deq();
                return e.first();
            endactionvalue
        endfunction
        
        equiv("put", spec.enq, impl.put);
        equiv("get", pop(spec), impl.get);
    endmodule

    module [Module] mkTestChecker();
        blueCheck( checkStack );
    endmodule

endpackage