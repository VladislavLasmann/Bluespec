package HelloBluespec;
    interface HelloBluespec;
        (* always_enabled, always_ready *) method Bool led();
    endinterface

    module mkHelloBluespec(HelloBluespec);
        Reg#(UInt#(25)) counter         <- mkReg(0);
        Reg#(Bool)        ledState      <- mkReg(False);

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
endpackage