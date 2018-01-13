package Blinky;

    interface HelloBluespec;
        (* always_enabled, always_ready *) method Bool led();
    endinterface

    module mkBlinky(HelloBluespec);
        Reg #(UInt #(25))   counter     <- mkReg(0);
        Reg #(Bool)         ledStatus   <- mkReg(False);

        // increments the counter every tact
        rule counterRule;
            if (counter == 25'h1FFFFFF)
                begin
                    counter     <= 0;
                    ledStatus   <= !ledStatus; 
                end
            else
                counter <= counter + 1;
        endrule

        rule displayHello (counter == 25'h1FFFFFF);
            $display("(%0d) HelloWorld", $time);
        endrule

        method Bool led();
            return led;
        endmethod

    endmodule: mkBlinky
endpackage: Blinky