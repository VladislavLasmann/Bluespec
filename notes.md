Usable commands for BSV
=======================

Rules
=====
<code>
rule $name$ $guard$;
    ....
endrule
</code>
    

A will be executed every time the guard is true
Example:
<code>
rule compute (y != 0);
    x <= 1;
endrule
</code>

The guard should be in ()

Methods
=======
value-methods
-------------
- like math. functions
- cannot alter the state of the circuit
- local intermediate values (=)
- return value
Example:
<code>
method int foo (int x, int y, int z);
    let sum = x + y;
    return sum + z;
endmethod
</code>

action-methods
--------------
- can alter the state of circuit (<=)
- no return value
- Example:
<code>
Reg #(int) sum <- mkReg(0);
method Action inc(int x);
    sum <= sum +x;
endmethod
</code>

action-value-methods
--------------------
- like action method but with return value
- return should be the last statement -> only one return per method
- !!! computes the right side values( of <=) and assigns everything at once !!!
- Example:
<code>
Reg #(int) sum <- mkReg(0);
method ActionValue #(int) inc(int x);
    sum <= sum +x;
    return sum*2;           // uses old value see !!!-point
endmethod
</code>