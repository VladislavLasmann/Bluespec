package Testbench;

import Mult::*; // alles aus Package Mult importieren

module mkTestbench(Empty);
    Mult_ifc m <- mkMult;

    rule gen_x;
        m.put_x(9);
    endrule

    rule gen_y;
        m.put_y(5);
    endrule

    rule drain;
        let w <- m.get_w();
        $display("Produkt = %d", w);
        $finish();
    endrule

endmodule: mkTestbench

endpackage: Testbench