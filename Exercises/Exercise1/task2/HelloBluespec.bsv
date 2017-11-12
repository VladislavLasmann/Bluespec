package HelloBluespec;
    module mkHelloBluespec(Empty);
        Reg#(UInt#(25)) counter         <- mkReg(0);

        rule count( msb(counter) == 0);
            counter <= counter + 1;
        endrule

        rule helloDisplay (readyDisplay) ;
            $display("(%0d) Hello World!", $time);
            counter         <= 0;
        endrule
    endmodule
endpackage