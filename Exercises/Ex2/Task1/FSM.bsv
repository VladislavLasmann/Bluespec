package FSM;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        Reg#(Bool)      seq1Val <- mkReg(False);
        Reg#(UInt#(8))  seq1Cnt <- mkReg(0);

        Stmt fsm_Stmt = {
            par
                seq
                    if( ! seq1Val )
                    begin
                        $display("[1] (%0d) Hello World", $time);
                        seq1Cnt <= seq1Cnt + 1;
                        if(seq1Cnt == 99)
                            seq1Val <= True;
                    end
                endseq

                seq
                    repeat (10) 
                        $display("[2] (%0d) Hello World", $time);                    
                    await(seq1Val);
                    $finish();
                endseq

            endpar
        };
        mkAutoFSM(fsm_Stmt);
    endmodule: mkFirstFSM

endpackage: FSM