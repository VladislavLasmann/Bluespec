package FSMTests;
    import StmtFSM::*;

    module mkFirstFSM(Empty);
        delay(100);
        Stmt myFirstFSM = {
            seq
                action
                    $display("(%0d) Hello World", $time);
                endaction
            endseq
        };
        mkAutoFSM( myFirstFSM ); 
    endmodule

endpackage