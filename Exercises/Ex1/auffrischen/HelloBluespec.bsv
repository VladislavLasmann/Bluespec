package HelloBluespec;
    interface HelloBluespec;
        (* always_enabled, always_ready *) method Bool led();
    endinterface

    module mkHelloBluespec(HelloBluespec);
        Reg #(UInt#(25))    counter <- mkReg(0);
        Reg #(Bool)         ledStat <- mkReg(False);

        rule count (counter != 25'h1ffffff);
            counter <= counter + 1;
        endrule

        rule helloDisplay (counter == 25'h1ffffff);
            $display("(%0d) Hello World!", $time);
            counter <= 0;
            ledStat <= ! ledStat;
        endrule

        method Bool led();
            return ledStat;
        endmethod

    endmodule

    module mkHelloTestbench(Empty);
        HelloBluespec   dut     <- mkHelloBluespec();
        Reg#(UInt#(32)) counter <- mkReg(0);

        rule endSimulation (counter == 200000000);
            $finish();
        endrule

        rule counterIncr;
            counter <= counter + 1;
        endrule
    endmodule

endpackage