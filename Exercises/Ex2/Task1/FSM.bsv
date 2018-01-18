package FSM;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Reg#(Bool)      seq1Val <- mkReg(False);

        Stmt fsm_Stmt = {
            par
                seq
                    $display("[1] (%0d) Hello World", $time);
                    delay(100);
                    seq1Val <= True;
                    $display("[1] (%0d) done", $time);
                endseq

                seq
                    repeat (10) 
                        $display("[2] (%0d) Hello World", $time);                    
                    await(seq1Val);
                    $display("[1] (%0d) done", $time);
                endseq

            endpar
        };
        mkAutoFSM(fsm_Stmt);
    endmodule: mkFirstFSM

endpackage: FSM