package HelloBluespec;
    module mkHelloBluespec(Empty);
        Reg#(UInt)  counter         <- mkReg(0);
        Reg#(UInt)  maxCounter      <- mkReg(25);
        Reg#(Bool)  readyDisplay    <- mkReg(False);

        rule count( !readyDisplay && counter < maxCounter);
            counter <= counter + 1;
        endrule;

        rule resetCounter (counter == maxCounter);
            counter         <= 0;
            readyDisplay    <= False;
        endrule

        rule helloDisplay (readyDisplay) ;
            readyDisplay <= False;
            $display("(%0d) Hello World!", $time);
        endrule
    endmodule
endpackage