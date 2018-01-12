package FSM;

import StmtFSM::*;

module mkFSM(Empty);
    Stmt myFirstFSM = {
        seq
            delay(100);
            action
                $display("(%0d): Hello World.", $time);
            endaction
        endseq
    };
    
    mkAutoFSM( myFirstFSM );
endmodule
endpackage
