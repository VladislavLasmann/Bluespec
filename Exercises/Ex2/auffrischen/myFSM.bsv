package FSMTests;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Stmt myFirstFSM = {
            seq
                delay(100);
                action
                    $display("(%0d) Hello World", $time);
                endaction
            endseq
        };
        mkAutoFSM( myFirstFSM ); 
    endmodule

    module mkSecondFSM(Empty);
        Reg#(Bool) aRegister    <- mkReg(False);

        Stmt mySecondFSM = {
            par
                seq
                    $display("(%0d) 1st part start", $time);
                    delay(100);
                    aRegister   <= True;
                    $display("(%0d) 1st part done", $time);
                endseq
                seq
                    repeat(10)
                        $display("(%0d) 2nd part", $time);
                    await(aRegister);
                    $display("(%0d) 2nd part done", $time);
                endseq
            endpar
        };

        mkFsm(mySecondFSM);
    endmodule

endpackage