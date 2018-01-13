package Blinky;
    module mkBlinky(Empty);
        Reg #(UInt #(25)) counter <- mkReg(0);


        // increments the counter every tact
        rule counterRule (counter != 25'h1FFFFFF);
            counter <= counter + 1;
        endrule

        rule displayHello (counter == 25'h1FFFFFF);
            $display("(%0d) HelloWorld", $time);
            counter <= 0;
        endrule
    endmodule
endpackage