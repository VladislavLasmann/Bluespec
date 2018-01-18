package FSM;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Stmt FSM_Stmt = {
            seq
                delay(100);
                action
                    $display("(%0d) HelloWorld", $time);
                endaction
            endseq
        };
        mkAutoFSM(FSM_Stmt);
    endmodule: mkFirstFSM

endpackage: FSM