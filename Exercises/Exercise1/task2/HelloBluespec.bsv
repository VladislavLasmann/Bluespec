package HelloBluespec;
    module mkHelloBluespec(Empty);
        Reg#(UInt#(25)) counter         <- mkReg(0);
        Reg#(Bool)      readyDisplay    <- mkReg(False);

        rule count( !readyDisplay && msb(counter) == 0);
            counter <= counter + 1;
        endrule

        rule resetCounter ( msb(counter) == 1);
            counter         <= 0;
            readyDisplay    <= True;
        endrule

        rule helloDisplay (readyDisplay) ;
            readyDisplay <= False;
            $display("(%0d) Hello World!", $time);
        endrule
    endmodule
endpackage