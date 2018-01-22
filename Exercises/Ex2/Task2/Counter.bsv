typed union tagged {
    void Invalid;
    data_t Valid;
} Maybe #(type data_t) deriving (Eq, Bits);

interface SimpleCounter;
    method Action incr(UInt#(32) v);
    method Action decr(UInt#(32) v);
    method UInt#(32) counterValue();
endinterface

module mkSimpleCounter(SimpleCounter); 
    
endmodule