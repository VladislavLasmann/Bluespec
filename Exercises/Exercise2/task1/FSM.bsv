package FSM;

import StmtFSM::*;

module mkFSM;
    Stmt myFirstFSM = {
        seq
            action
                $display("Hello World.");
            endaction
        endseq
    };

    StmtFSM     myFSM  <- mkAutoFSM( myFirstFSM );

    rule printHelloWorldEachHundredCycles:
        myFSM.delay( 100 );
    endrule

endmodule
endpackage