package FSM;

import StmtFSM::*;

module mkFSM(Empty);
    Stmt myFirstFSM = {
        seq
            action
                $display("Hello World.");
            endaction
            delay(100);
        endseq
    };
    
    mkAutoFSM( myFirstFSM );
endmodule
endpackage
