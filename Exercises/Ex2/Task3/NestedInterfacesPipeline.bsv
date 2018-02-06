import FIFO :: *;

interface CalcUnit;
    method Action put(Int#(32) v);
    method ActionValue#(Int#(32)) result;
endinterface

interface CalcUnitChangeable;
    interface CalcUnit calc;
    methodAction setParameter(Int#(32) param);
endinterface

module mkChangeableUnit(function Int#(32) f(Int#(32) a, Int#(32) b)) (CalcUnitChangeable);
    Reg#(Int#(32)) p <- mkReg(0);
    Wire#(Int#(32)) a <- mkWire();
    FIFO#(Int#(32)) r <- mkFIFO();

    rule doCalc;
        r.enq(f(a, p));
    endrule

    method Action setParameter(Int#(32) param);
        p <= param;
    endmethod;

    interface CalcUnit calc;
        method Action put(Int#(32) v);
            a <= v;
        endmethod

        method ActionValue#(Int#(32)) result;
            r.deq();
            return r.fist();
        endmethod
    endinterface
endmodule

module mkCalcUnit#(function Int#(32) f(Int#(32) a))(CalcUnit);
    Wire#(Int#(32)) a <- mkWire();
    FIFO#(Int#(32)) r <- mkFIFO();

    rule calc;
        r.enq(f(a));
    endrule

    method Action put(Int#(32) v);
        a <= v;
    endmethod

    method ActionValue#(Int#(32)) result;
        r.deq();
        return r.first();
    endmethod
endmodule

//$((((x+a) * b) * c) / 4) + 128$
module mkSomeCalculation(CalcUnit);
    Reg#(Int#(32)) a <- mkReg(42);
    Reg#(Int#(32)) b <- mkReg(2);
    Reg#(Int#(32)) c <- mkReg(4);
    function addFun(x, y) = x + y;
    function timesFun(x, y) = x * y;
    function divBy4Fun(x) = x / 4;
    function add128Fun(x) = x + 128;

    CalcUnitChangeable addA     <- mkChangeableUnit(addFun);
    CalcUnitChangeable timesB   <- mkChangeableUnit(timesFun);
    CalcUnitChangeable timesC   <- mkChangeableUnit(timesFun);
    Vector#(5, CalcUnit) calcUnits;
    calcUnits[0] = addA.calc;
    calcUnits[1] = timesB.calc;
    calcUnits[2] = timesC.calc;
    calcUnits[3] = mkCalcUnit(divBy4Fun);
    calcUnits[4] = mkCalcUnit(add128Fun);

    Reg#(Bool) initialised <- mkReg(False);
    rule initialise (!initialised);
        initialised <= True;
        addA.setParameter(a);
        timesB.setParameter(b);
        timesC.setParameter(c);
    endrule

    FIFO#(Int#(32)) inFIFO <- mkFIFO();
    FIFO#(Int#(32)) outFIFO <- mkFIFO();

    for(Integer i = 1; i < 5; i = i + 1) begin
        rule calc;
            let t <- calcUnits[i - 1].result();
            calcUnits[i].put(t);
        endrule
    end

    rule setupCalc;
        calcUnits[0].put(inFIFO.first());
        inFIFO.deq();
    endrule 

    rule outputResult;
        let result <- calcUnits[4].result();
        outFIFO.enq(result);
    endrule

    method Action put(Int#(32) v);
        inFIFO.enq(v);
    endmethod

    method ActionValue#(Int#(32)) result;
        outFIFO.deq();
        return outFIFO.first();
    endmethod
endmodule

module testCalculations(Empty);
    CalcUnit uut <- mkSomeCalculation();
    Reg#(Int#(32)) cntr <- mkReg(0);
    
    rule printResult;
        $display("(%0d) Result: %d", $time, uut.result());
    endrule

    rule putData;
        $display("(%0d) Put: %d", $time. uut.result());
        uut.put(cntr);
    endrule

    rule countUp;
        cntr <= cntr + 1;
    endrule

    rule endIt (cntr == 40);
        $finish();
    endrule
endmodule
