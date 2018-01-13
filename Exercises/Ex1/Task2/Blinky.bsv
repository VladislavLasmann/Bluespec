package Blinky;

    interface HelloBluespec;
        (* always_enabled, always_ready *) method Bool led();
    endinterface

    module mkBlinky(HelloBluespec);
        Reg #(UInt #(25))   counter     <- mkReg(0);
        Reg Bool            ledStatus   <- mkReg(False);

        // increments the counter every tact
        rule counterRule (counter != 25'h1FFFFFF);
            counter <= counter + 1;
        endrule

        rule displayHello (counter == 25'h1FFFFFF);
            $display("(%0d) HelloWorld", $time);
            counter     <= 0;
            ledStatus   <= !ledStatus; 
        endrule

        method Bool led();
            return led;
        endmethod

    endmodule: mkBlinky
endpackage: Blinky