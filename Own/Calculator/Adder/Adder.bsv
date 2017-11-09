package Adder;

interface Adder_ifc;
    method Action               put_x (int xx);
    method Action               put_y (int yy);
    method ActionValue  #(int)  get_w ();
endinterface: Adder_ifc

module mkAdder(Adder_ifc);
    Reg #(int)  w       <- mkRegU;
    Reg #(int)  x       <- mkRegU;
    Reg #(int)  y       <- mkRegU;
    Reg #(Bool) got_x   <- mkReg(False);
    Reg #(Bool) got_y   <- mkReg(False);
    Reg #(Bool) computed<- mkReg(False);

    rule compute ( got_x && got_y );
        w <= x + y;
        computed <= True;
    endrule

    method Action put_x (int xx) if (! got_x);
        x <= xx; 
        w <= 0;
        got_x <= True;
    endmethod

    method Action put_y (int yy) if (! got_y);
        y <= yy; 
        got_y <= True;
    endmethod

    method ActionValue #(int) get_w() if ( computed && got_x && got_y );
        got_x <= False; 
        got_y <= False;
        computed <= False;
        return w;
    endmethod

endmodule: mkAdder

endpackage: Adder