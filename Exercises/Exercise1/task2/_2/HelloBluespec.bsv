package HelloBluespec;
    interface HelloBluespec;
        method Bool led();
    endinterface

    module mkHelloBluespec(HelloBluespec);
        Reg#(UInt#(25)) counter         <- mkReg(0);

        rule count( msb(counter) != 'h1ffffff);
            counter <= counter + 1;
        endrule

        rule helloDisplay ( msb(counter) == 'h1ffffff);
            $display("(%0d) Hello World!", $time);
            counter <= 0;
        endrule
    endmodule
endpackage