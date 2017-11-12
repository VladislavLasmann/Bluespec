package HelloALU;

    interface HelloALU;
        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))   getResult();
    endinterface;

    module mkSimpleALU(HelloALU);
        typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);
        Reg#(Int#(32))  firstOperand    <- mkRegU;
        Reg#(Int#(32))  secondOperand   <- mkRegU;
        Reg#(Int#(32))  result          <- mkRegU;

        method Action   setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            firstOperand    <= a;
            secondOperand   <= b;

            if( op == AluOps.Mul )
                executeMultiplication();
            else if( op == AluOps.Div )
                executeDivision();
            else if( op == AluOps.Add )
                executeAddition();
            else if( op == AluOps.Sub )
                executeSubtraction();
            else if( op == AluOps.And )
                executeBinaryAnd();
            else if( op == AluOps.Or )
                executeBinaryOr();
        endmethod

        method ActionValue#(Int#(32))   getResult();
            return result;
        endmethod

        method Action executeAddition;

        endmethod

        method Action executeSubtraction;

        endmethod

        method Action executeMultiplication;

        endmethod

        method Action executeDivision;

        endmethod

        method Action executeBinaryAnd;

        endmethod

        method Action executeBinaryOr;

        endmethod

    endmodule

    module mkTestbench(Empty);


    endmodule

endpackage;