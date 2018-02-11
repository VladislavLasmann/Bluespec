package circularBuffer;
    import Vector::*;

    module mkTestFIFO(FIFO);
        // Pointer for indizes. Max Bit size: 4, because max index is 15
        // Overflow desired!
        Reg#(UInt#(4))  readPntr    <- mkReg(0);
        Reg#(UInt#(4))  writePntr   <- mkReg(0);
        // Circulat Buffer:
        Vector#(16, Reg#(Int#(16))) buffer;

        method Action put(Int#(16) e) if ((writePntr + 1) != readPntr);
            buffer[writePntr] <= e;
            writePntr <= writePntr + 1;
        endmethod

        method ActionValue#(Int#(16)) get() if (readPntr != dataPntr);
            readPntr <= readPntr + 1;
            return buffer[readPntr];
        endmethod
    endmodule


endpackage