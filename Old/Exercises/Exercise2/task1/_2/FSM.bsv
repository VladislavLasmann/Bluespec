package FSM;

import StmtFSM:: *;

module mkFSM(Empty);
    Reg#(Bool)  firstSeqFinished <- mkReg(False);
    Reg#(int)   secondSeqCounter <- mkReg(0);


    Stmt myFSM = {
        par
            seq
                delay(100);
                action
                    $display("(%0d) First seq: Hello World.", $time);
                    firstSeqFinished <= True;
                endaction
            endseq

            seq
                repeat( 10 )
                    $display("(%0d) Second seq: Hello World.", $time);

                while( !firstSeqFinished )
                    delay(1);
            endseq
        endpar
    };

endmodule


endpackage