package FSM;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Stmt fsm_Stmt = {
            seq
                delay(100);
                action
                    $display("(%0d) HelloWorld", $time);
                endaction
            endseq
        };
        mkAutoFSM(fsm_Stmt);
    endmodule: mkFirstFSM

endpackage: FSM