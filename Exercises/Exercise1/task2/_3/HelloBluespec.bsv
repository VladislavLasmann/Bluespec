package HelloBluespec;
    interface HelloBluespec;
        (* always_enabled, always_ready *) method Bool led();
    endinterface

    module mkHelloBluespec(HelloBluespec);
        Reg#(UInt#(25)) counter     <- mkReg(0);
        Reg#(Bool)      ledState    <- mkReg(False);

        rule count;
            if ( counter == 'h1ffffff)  begin
                counter <= 0;
                ledState <= !ledState;
            end
            else                        
                counter <= counter + 1;
        endrule

        rule helloDisplay ( counter == 'h1ffffff);
            $display("(%0d) Hello World!", $time);
        endrule

        method Bool led();
            return ledState;
        endmethod
    endmodule

    // this testbench works with 100MHz and should run 2 sec
    module mkHelloTestbench(Empty);
        HelloBluespec   hello   <- mkHelloBluespec;
        // counter for clock cycles, 28 Bits because (2*10^8)10 = (BEBC200)16 => 7*4 Bits = 28 Bits
        Reg#(UInt#(28)) counter <- mkReg(0);

        rule count;
                counter <= counter + 1;
        endrule

        rule (counter == 200000000 )
            $finish(0);
        endrule
    endmodule
endpackage