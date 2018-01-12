package Mult;

interface Mult_ifc;
    method Action put_x(int xx);
    method Action put_y(int yy);
    method ActionValue #(int) get_w();  // w = xx * yy
endinterface: Mult_ifc

module mkMult(Mult_ifc);
    Reg #(int)  w   <- mkRegU;
    Reg #(int)  x   <- mkRegU;
    Reg #(int)  y   <- mkRegU;
    Reg #(Bool) got_x   <- mkReg (False);
    Reg #(Bool) got_y   <- mkReg (False);

    rule compute((y != 0) && got_x && got_y);
        if (lsb(y) == 1)    w <= w + x;
        x <= x << 1;
        y <= y >> 1;
    endrule

    method Action put_x(int xx) if (! got_x);
        x <= xx;
        w <= 0;
        got_x <= True;
    endmethod

    method Action put_y(int yy) if (! got_y);
        y <= yy;
        got_y <= True;
    endmethod

    method ActionValue #(int) get_w() if ((y == 0) && got_x && got_y);
        got_x <= False;
        got_y <= False;
        return w;
    endmethod

endmodule: mkMult

endpackage: Mult