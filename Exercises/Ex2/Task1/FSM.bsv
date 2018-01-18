package FSM;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Stmt fsm_Stmt = {
            Reg#(Bool)      seq1Val <- mkReg(False);
            Reg#(UInt#(8))  seq1Cnt <- mkReg(0);
            par
                seq
                    $display("[1] (%0d) Hello World", $time);
                    seq1Cnt <= seq1Cnt + 1;
                endseq

                seq
                    repeat (10) 
                        $display("[2] (%0d) Hello World", $time);                    
                    await(seq1Val);
                endseq

            endpar
        };
        mkAutoFSM(fsm_Stmt);
    endmodule: mkFirstFSM

endpackage: FSM