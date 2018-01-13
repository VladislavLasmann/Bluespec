package Blinky;
    module mkBlinky(Empty);
    Reg #(UInt #(25)) counter <- mkReg(0);


    // increments the counter every tact
    rule counter if (counter != 25'h1FFFFFFFF);
        counter <= counter + 1;
    endrule

    rule displayHello if (counter == 25'h1FFFFFFFF);
        $display("(%0d) HelloWorld", $time);
        counter <= 0;
    endmodule
endpackage