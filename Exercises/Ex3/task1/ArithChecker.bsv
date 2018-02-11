package ArithChecker;
    import BlueCheck::*;

    module[BlueCheck] mkArithSpec ();
        function Bool addComm(Int#(4) x, Int#(4) y) =
            x + y == y + x;

        function Bool addAssoc(Int#(4) x, Int#(4) y, Int#(4) z) =
            x + (y + z) == (x + y) + z;

        
        function Bool subComm(Int#(4) x, Int#(4) y);
            let result = False;
            if( x < y )
                result = x - y < y - x;
            else if ( x > y)
                result = x - y > y - x;
            else
                result = x - y == y - x;
            
            return result;
        endfunction
        
        function Bool mulComm(Int#(4) x, Int#(4) y) =
            x * y == y * x;
        function Bool mulAssoc(Int#(4) x, Int#(4) y, Int#(4) z) =
            x * (y * z) == (x * y) * z;
        


        prop("addComm"  , addComm);
        prop("AddSoc"   , addAssoc);
        //prop("subComm"  , subComm);
        prop("mulComm"  , mulComm);
        prop("mulAssoc" , mulAssoc);
    endmodule

    module [Module] mkArithChecker ();
        blueCheck(mkArithSpec);
    endmodule
    
endpackage