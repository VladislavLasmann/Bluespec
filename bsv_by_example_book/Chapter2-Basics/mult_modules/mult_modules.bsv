// Working with multiple modules in a file

package Tb;

module mkTb(Empty);
    Ifc_type ifc <- mkModuleDeepThought;

    rule theUltimateAnswer;
        $display("Hello World! The answer is: %0d", ifc.the_answer(10, 15, 17) );
        $finish(0);
    endrule
endmodule: mkTb

// Interface is like a datatype
interface Ifc_type;                             
    method int the_answer (int x, int y, int z);
endinterface: Ifc_type

// mkModuleDeepThought is an Ifc_type -type
module mkModuleDeepThought(Ifc_type);               
    method int the_answer (int x, int y, int z);
        return x + y + z;
    endmethod
endmodule: mkModuleDeepThought

endpackage: Tb