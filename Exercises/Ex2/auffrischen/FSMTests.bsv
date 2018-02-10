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

        mkAutoFSM(mySecondFSM);
    endmodule

    module mkThirdFSM(Empty);
        Reg#(UInt#(12)) counter <- mkReg(0);
        PulseWire       pw      <- mkPulseWire();
        Reg#(UInt#(12)) i       <- mkReg(0);

        rule count (counter < 99);
            counter <= counter + 1;
        endrule

        rule resetCount (counter == 99);
            counter <= 0;
            pw.send();
        endrule

        Stmt thirdFSM = {
            seq
                for( i <= 0; i < 20; i <= i + 1) seq
                    $display("(%0d) Iteration %d", $time, i);
                endseq

                $finish();
            endseq
        };    
        FSM myFSM <- mkFSMWithPred(thirdFSM, pw);
        rule startFSM( myFSM.done() );
            myFSM.start();
        endrule
    endmodule

endpackage