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

endpackage