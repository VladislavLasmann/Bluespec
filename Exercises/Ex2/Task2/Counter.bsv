typed union tagged {
    void Invalid;
    data_t Valid;
} Maybe #(type data_t) deriving (Eq, Bits);

interface SimpleCounter;
    method Action incr(UInt#(32) v);
    method Action decr(UInt#(32) v);
    method UInt#(32) counterValue();
endinterface

module mkSimpleCounter(SimpleCounter); 
    RWire#(UInt#(32)) incrWire <- mkRWire();
    RWire#(UInt#(32)) decrWire <- mkRWire();

    Reg#(UInt#(32)) cntr <- mkReg(0);
    
    rule count;
        let counterVal = cntr;
        Maybe#(UInt#(32)) maybeIncr = incrWire.wget();
        Maybe#(UInt#(32)) maybeDecr = decrWire.wget();

        UInt#(32) incrVal = 0;
        UInt#(32) decrVal = 0;

        if(isValid(maybeIncr)) begin
            incrVal = fromMaybe(?, maybeIncr);
        end
        if(isValid(maybeDecr)) begin
            decrVal = fromMaybe(?, maybeDecr);
        end

        cntr <= cntr + incrVal - decrVal;
    endrule: count

    method Action incr(UInt#(32) v);
        incrWire.wset(v);
    endmethod
    method Action decr(UInt#(32) v);
        decrWire.wset(v);
    endmethod
    method UInt#(32) counterValue();
        return cntr;
    endmethod
endmodule

module mkCounterTest(Empty);
    SimpleCounter uut <- mkSimpleCounter();
    Stmt testbench = {
        seq
            action
                uut.incr(5);
            endaction
            action
                $display("%d", uut.counterValue());
                uut.incr(5);
                uut.decr(6);
            endaction
            action
                $display("%d", uut.counterValue());
                uut.decr(4);
            endaction
            action
                $display("%d", uut.counterValue());
            endaction
        endseq
    };

    mkAutoFSM(testbench);
endmodule