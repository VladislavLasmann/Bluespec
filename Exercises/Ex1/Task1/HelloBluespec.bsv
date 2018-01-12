package HelloBluespec;
    module mkHelloBluespec(Empty);
        rule helloDisplay;
            $display("(%0d) Hello World!", $time);
        endrule
    endmodule
endpackage: HelloBluespec