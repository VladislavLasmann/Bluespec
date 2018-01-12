package Testbench;

import Div::*;

module mkTestbench(Empty);
    Div_ifc div <- mkDiv;

    rule gen_x;
        div.put_x(45);
    endrule
    
    rule gen_y;
         div.put_y(9);
    endrule

    rule drain;
        let w <- div.get_w();
        $display("Quotient= %d", w);
        $finish();
    endrule

endmodule: mkTestbench
endpackage: Testbench