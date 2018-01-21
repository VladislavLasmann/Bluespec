typedef enum{Mul,Div,Add,Sub,And,Or} AluOps deriving (Eq, Bits);
typedef union tagged {UInt#(32) Unsigned; Int#(32) Signed;} SignedOrUnsigned deriving (Bits, Eq);

interface ALU_ifc;
    method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
    method ActionValue #(SignedOrUnsigned) getResult();
endinterface: ALU_ifc

module mkALU(ALU_ifc);

    Reg#(AluOps) operation          <- mkRegU;
    Reg#(SignedOrUnsigned) opA      <- mkReg(tagged Signed 0);
    Reg#(SignedOrUnsigned) opB      <- mkReg(tagged Signed 0);
    Reg#(SignedOrUnsigned) result   <- mkReg(tagged Signed 0);
    Reg#(Bool) readyForCalculation  <- mkReg(False);
    Reg#(Bool) calculated           <- mkReg(False);

    rule calculateSigned (opA matches tagged Signed .va &&& opB matches tagged Signed .vb &&& readyForCalculation);
        Int#(32) tmpResult = 0;
        case(operation)
            Mul: tmpResult = va * vb;
            Div: tmpResult = va / vb;
            Add: tmpResult = va + vb;
            Sub: tmpResult = va - vb;
            And: tmpResult = va & vb;
            Or: tmpResult = va | vb;
        endcase
        readyForCalculation <= False;
        calculated <= True;
        result <= tagged Signed tmpResult;
    endrule

    rule calculateUnsigned (opA matches tagged Unsigned .va &&& opB matches tagged Unsigned .vb &&& readyForCalculation);
        UInt#(32) tmpResult = 0;
        case(operation)
            Mul: tmpResult = va * vb;
            Div: tmpResult = va / vb;
            Add: tmpResult = va + vb;
            Sub: tmpResult = va - vb;
            And: tmpResult = va & vb;
            Or: tmpResult = va | vb;
        endcase
        readyForCalculation <= False;
        calculated <= True;
        result <= tagged Unsigned tmpResult;
    endrule

    function Bool isUnsigned(SignedOrUnsigned v);
        if(v matches tagged Unsigned .va)
            return True;
        else
            return False;
    endfunction

    rule dumpInvalid (readyForCalculation && isUnsigned(opA) != isUnsigned(opB) );
        $display("Invalid combination of Signed and Unsigned Operands");
        readyForCalculation <= False;
        calculated <= False;
    endrule


    method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b) if (! readyForCalculation );
        operation   <= op;
        opA         <= a;
        opB         <= b;
        readyForCalculation <= True;
        calculated  <= False;
    endmethod

    method ActionValue #(SignedOrUnsigned) getResult();
        calculated <= False;
        return result;
    endmethod
endmodule: mkALU

module mkALUTestbench(Empty);
    ALU_ifc  uut                <- mkALU();
    Reg#(UInt#(8)) testState    <- mkReg(0);

    rule checkMul (testState == 0);
        uut.setupCalculation(Mul, tagged Unsigned 4, tagged Unsigned 5); 
        testState <= testState + 1;
    endrule
    rule checkDiv (testState == 2);
        uut.setupCalculation(Div, tagged Unsigned 40, tagged Unsigned 5); 
        testState <= testState + 1;
    endrule
    rule checkAdd (testState == 4);
        uut.setupCalculation(Add, tagged Unsigned 4, tagged Unsigned 5); 
        testState <= testState + 1;
    endrule
    rule checkSub (testState == 6);
        uut.setupCalculation(Sub, tagged Unsigned 4, tagged Unsigned 5); 
        testState <= testState + 1;
    endrule
    rule checkAnd (testState == 8);
        uut.setupCalculation(And, tagged Unsigned 32'hA, tagged Unsigned 32'hA); 
        testState <= testState + 1;
    endrule
    rule checkOr (testState == 10);
        uut.setupCalculation(Or, tagged Unsigned 32'hA, tagged Unsigned 32'hA); 
        testState <= testState + 1;
    endrule

    rule printResults (unpack(pack(testState)[0])); 
        $display("Result: %d", uut.getResult()); 
        testState <= testState + 1;
    endrule

    rule endTestbench (testState > 10);
        $finish();
    endrule
endmodule