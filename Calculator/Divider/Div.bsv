package Div;

interface Div_ifc;
    method Action               put_x(int xx);
    method Action               put_y(int yy);
    method ActionValue  #(int)  get_w();
endinterface: Div_ifc

module mkDiv(Div_ifc);
    Reg #(int)  x           <- mkRegU;
    Reg #(int)  y           <- mkRegU;
    Reg #(int)  w           <- mkRegU;
    Reg #(int)  remainder   <- mkRegU;
    Reg #(Bool) got_x       <- mkReg(False); 
    Reg #(Bool) got_y       <- mkReg(False);
    Reg #(Bool) computed    <- mkReg(False);


    rule compute ( (!computed) && got_x && got_y );    //TODO: GUARD
        if (x < y) 
            computed <= True;
        else begin
            x <= x - y;
            w <= w + 1;
        end
    endrule

    method Action put_x(int xx) if (! got_x);
        x <= xx;
        got_x <= True;
        w <= 0;
    endmethod

    method Action put_y(int yy) if (! got_y);
        y <= yy;
        got_y <= True;
    endmethod

    method ActionValue #(int) get_w() if (computed && got_x && got_y);
        got_x <= False;
        got_y <= False;
        computed <= False;

        return w;
    endmethod

endmodule: mkDiv

endpackage: Div