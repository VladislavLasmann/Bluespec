package Testbench;

import Mult::*;    // import everything

module mkTestbench (Empty);
    Mult_ifc m <- mkMult;

    rule gen_x;
        m.put_x (9);
    endrule

    rule gen_y;
        m.put_y (5);
    endrule

    rule drain;
        let w <- m.get_w ();
        $display ("Product = %d", w);
        $finish();
    endrule
endmodule: mkTestbench

endpackage: Testbench