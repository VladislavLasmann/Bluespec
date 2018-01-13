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
            return ledStatus;
        endmethod

    endmodule: mkBlinky

    module mkTestbench(Empty);
        Blinky blinky <- mkBlinky();
        // f = 100MHz , T = 1/f  => T = 1*10^(-8)s
        // Testbench should run 2s, so required bits for counter:
        // (2*1*10^8)_10 = (BEBC200)_16 => 7*4Bits => 28 Bits
        Reg #(UInt #(28)) counter <- mkReg(0);

        rule count;
            counter <= counter + 1;
        endrule

        rule finish ( counter == 28'hBEBC200 );
            $finish();
        endrule

    endmodule: mkTestbench
endpackage: Blinky