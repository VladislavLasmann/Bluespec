package Testbench;

import Sub::*;

module mkTestbench(Empty);
    Sub_ifc sub <- mkSub;

    rule gen_x;
        sub.put_x(5);
    endrule

    rule gen_y;
        sub.put_y(9);
    endrule

    rule drain;
        let w <- sub.get_w();
        $display("Sum= %d", w);
        $finish();
    endrule

endmodule: mkTestbench

endpackage: Testbench