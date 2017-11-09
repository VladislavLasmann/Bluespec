/**
    Very basic 'Hello World'
*/

package Tb;

module mkTb(Empty);
    
    rule greet;
        $display("Hello World!");
        $finish(0);
    endrule
    
endmodule: mkTb

endpackage: Tb