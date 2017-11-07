package Testbench;

import Adder::*;

module mkTestbench(Empty);
    Adder_ifc adder <- mkAdder;

    rule gen_x;
        adder.put_x(5);
    endrule

    rule gen_y;
        adder.put_y(9);
    endrule

    rule drain;
        let w <- adder.get_w();
        $display("Sum= %d", w);
        $finish();
    endrule

endmodule: mkTestbench

endpackage: Testbench