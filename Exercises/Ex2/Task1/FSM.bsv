package FSM;
    import StmtFSM::*;
    import PulseWire::*;

    module mkSecondFSM(Empty);
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

    module mkThirdFSM(Empty);
        Reg#(Uint#(12)) counter <- mkReg(0);
        PulseWire        pw <- mkPulseWire();
        Reg#(UInt#(12)) i <- mkReg(0);

        rule count (counter < 99 );
            counter <= counter + 1;
        endrule 

        rule resetCount (counter == 99);
            counter <= 0;
            pw.send();
        enrule;

        Stmt thirdStmt = {
            seq 
                for( i <= 0; i < 20; i <= i + 1)
                    seq
                        $display("(%0d) Iteration %d", $time, i);
                    endseq
                    $finish();
            endseq
        };

        FSM myFSM <- mkFSMWithPred(thirdStmt, pw);
        rule startFSM(myFSM.done());
            myFSM.start();
        endrule
        
    endmodule: mkThirdFSM


endpackage: FSM