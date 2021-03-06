import GetPut::*;

interface PairAverage;
    interface Put#(int) data_in;
    interface Get#(int) pair_average;
endinterface: PairAverage

module mkPairAverage(PairAverage);
    Reg#(int) oldval <- mkReg(0);
    Reg#(int) newval <- mkReg(0);
    Reg#(Bool) got_old <- mkReg(False);
    Reg#(Bool) got_new <- mkReg(False);

    interface Put data_in;
        method Action put(int val);
            if( got_new ) begin
                oldval <= newval;
                got_old <= True; 
            end
            newval <= val;
            got_new <= True;
        endmethod: put
    endinterface: data_in

    interface Get pair_average;
        method ActionValue#(int) get() if (got_new && got_old);
            return (oldval + newval) / 2;
        endmethod
    endinterface: pair_average
endmodule: mkPairAverage

module top(Empty);
    Reg#(int)   invalue <- mkReg(0);
    PairAverage pa      <- mkPairAverage;

    rule average; // kann blocken
        $display("Average of last two items: %d", pa.pair_average.get());
    endrule

    rule counter;
        invalue <= invalue + 4;
        pa.data_in.put(invalue);
        $display("Entered %d", invalue);
        if( invalue == 32)
            $finish;
    endrule
endmodule: top