package FSM;

import StmtFSM::*;

module mkFSM(Empty);
    Stmt myFirstFSM = {
        seq
            action
                $display("Hello World.");
                delay(100);
            endaction
        endseq
    };
    
    mkAutoFSM( myFirstFSM );
endmodule
endpackage
