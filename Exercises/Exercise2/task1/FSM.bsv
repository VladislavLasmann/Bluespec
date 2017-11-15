package FSM;

import StmtFSM::*;

module mkFSM(Empty);
    Stmt myFirstFSM = {
        seq
            action
                $display("Hello World.");
            endaction
        endseq
    };

    AutoFSM     myFSM  <- mkAutoFSM( myFirstFSM );

    rule printHelloWorldEachHundredCycles;
        myFSM.delay( 100 );
    endrule
endmodule
endpackage
