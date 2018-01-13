package ALU;

    typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);

    interface ALU_ifc;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue #(Int#(32)) getResult();
    endinterface

    module mkALU(ALU_ifc);
        Reg#(Int #(32)) val1        <- mkRegU;
        Reg#(Int #(32)) val2        <- mkRegU;
        Reg#(Int #(32)) result      <- mkReg(0);
        Reg#(AluOps)    operation   <- mkRegU;
        
        Reg#(Bool) valuesSet        <- mkReg(False);
        Reg#(Bool) calculated       <- mkReg(False);

        rule calculate (valuesSet && ! calculated);
            Int#(32) tmpResult = 0;
            case(operation)
                Mul: tmpResult = val1 * val2;
                Div: tmpResult = val1 / val2;
                Add: tmpResult = val1 + val2;
                Sub: tmpResult = val1 + val2;
                And: tmpResult = val1 & val2;
                Or:  tmpResult = val1 | val2;
            endcase
            result <= tmpResult;
            calculated <= True;
        endrule

        method Action setupCalculation(AluOps op, Int #(32) a, Int#(32) b);
            val1 <= a;
            val2 <= b;
            result <= 0;
            operation <= op;
            valuesSet <= True;
        endmethod

        method ActionValue #(Int #(32)) getResult();
            if( calculated)
            begin
                result <= 0;
                valuesSet <= True;
                calculated <= False;
            end
            return result;
        endmethod
    endmodule: mkALU

    module mkTestbench(Empty);
        ALU_ifc alu <- mkALU;
        Reg#(UInt#(3)) testState <- mkReg(0);
        Reg#(Bool) printResult <- mkReg(False);

        rule checkMul (testState == 0);
            alu.setupCalculation(Mul, 4, 5);
            $display("%d * %d", 4, 5);
            printResult <= ! printResult;
        endrule
        rule checkDiv (testState == 1);
            alu.setupCalculation(Div, -10, 5);
            $display("%d / %d", -10, 5);
            printResult <= ! printResult;
        endrule
        rule checkAdd (testState == 2);
            alu.setupCalculation(Add, -3, 5);
            $display("%d + %d", -3, 5);
            printResult <= ! printResult;
        endrule
        rule checkSub (testState == 3);
            alu.setupCalculation(Sub, 4, 5);
            $display("%d - %d", 4, 5);
            printResult <= ! printResult;
        endrule
        rule checkAnd (testState == 4);
            alu.setupCalculation(And, 4, 5);
            $display("%d & %d", 4, 5);
            printResult <= ! printResult;
        endrule
        rule checkOr (testState == 5);
            alu.setupCalculation(Or, 4, 5);
            $display("%d | %d", -1, 5);
            printResult <= ! printResult;
        endrule
        rule printResult;
            $display("= %d", alu.getResult());
            testState <= testState + 1;
            printResult <= ! printResult;
        endrule
        rule finish (testState == 6);
            $display("Test finished...");
            $finish();
        endrule
    
    endmodule: mkTestbench
endpackage: ALU