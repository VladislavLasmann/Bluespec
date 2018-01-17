import GetPut :: *;
import FIFOF :: *;

interface Shifter_Ifc;
    interface Put #(Bit #(8)) put_x;
    interface Put #(Bit #(3)) put_y;
    interface Get #(Bit #(8)) get_z;    // z = x << z
endinterface

module mkShifter (Shifter_Ifc);
    FIFOF #(Bit #(8)) fifo_in_x <- mkFIFOF;
    FIFOF #(Bit #(3)) fifo_in_y <- mkFIFOF;
    FIFOF #(Bit #(8)) fifo_out_z <- mkFIFOF;

    Reg #(Maybe #(Bit #(8))) rg_x1 <- mkReg (tagged Invalid);
    Reg #(Bit #(3)) rg_y1 <- mkRegU;

    Reg #(Maybe #(Bit #(8))) rg_x2 <- mkReg (tagged Invalid);
    Reg #(Bit #(3)) rg_y2 <- mkRegU;

    rule rl_all_together;
        // Stufe 0
        Bit #(3) y0 = ?;
        if (fifo_in_x.notEmpty) begin
            let x0 = fifo_in_x.first; fifo_in_x.deq;
                y0 = fifo_in_y.first; fifo_in_y.deq;
            rg_x1 <= tagged Valid((y0 [0] == 0) ? x0 : (x0 << 1));
        end else
            rg_x1 <= tagged Invalid;
        rg_y1 <= y0;

        // Stufe 1
        if (rg_x1 matches tagged Valid .x1)
            rg_x2 <= tagged Valid ((rg_y1 [1] == 0)? x1 : (x1 << 2));
        else
            rg_x2 <= tagged Invalid;
        rg_y2 <= rg_y1;

        // Stufe 2
        if (rg_x2 matches tagged Valid .x2)
            fifo_out_z.enq( ((rg_y2[2] == 0) ? x2 : (x2 << 4)) );
    endrule

    interface put_x = toPut (fifo_in_x);
    interface put_y = toPut (fifo_in_y);
    interface get_z = toGet (fifo_out_z);
endmodule: mkShifter

module mkTestbench (Empty);
    Shifter_Ifc shifter <- mkShifter;

    Reg #(Bit #(4)) rg_y <- mkReg(0);

    rule rl_gen (rg_y < 8);
        shifter.put_x.put (8'h01);
        shifter.put_y.put (truncate (rg_y));
        rg_y <= rg_y + 1;
    endrule
    rule rl_drain;
        let z <- shifter.get_z.get ();
        $display("Output = %8b", z);
        if( z == 8'h80)
            $finish();
    endrule
endmodule: mkTestbench