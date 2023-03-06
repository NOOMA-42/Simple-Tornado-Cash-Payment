pragma circom 2.0.0;

// The first this to know is that all ciruits have signals (wires in the
// arithmetic circuit), and that while some of these signals are "input"s, not
// all are. Thus, a circom program really does two things:
//    * It expresses a set of rank-1 constraints over the signals.
//    * It expresses how non-input signals can be computed
//
// Sometimes these two tasks align, e.g. "c is a * b", where a, b are inputs and
// c is not. Sometimes though, the non-input signals are most easily computed
// using fancy operations (e.g., bit operations) not present in the circuit. In
// such situations, the constraints and the signal computation instructions
// will diverge.

// We start with `Num2Bits`, a circuit which features:
//
//    * arrays of signals
//    * using loops to do:
//       * do many assignments
//       * enforce many constraints
//       * build linear combinations
//    * the `<--` operator (for computing signal values)
//    * the `===` operator (for expressing constraints)
//    * building variables that store linear combinations of symbols

// test
template Multiplier2(){
   //Declaration of signals
   signal input in1;
   signal input in2;
   signal output out <== in1 * in2;
}

template IsZero(){
    signal input in1;
    signal output out;
    signal inv;
    inv <-- in1!=0 ? 1/in1 : 0;
    out <== -in1 * inv + 1;
    in1 * out === 0;
}

/*
 * Decomposes `in` into `b` bits, given by `bits`.
 * Least significant bit in `bit[0]`.
 */
template Num2Bits(b) {
    signal input in1;
    signal output bits[b];
    var sum_of_bits = 0;
    var exp2 = 1;
    
    //in1*0 === 0;
    for (var i = 0; i < b; i++) {
    // First, compute the bit values
        // Use `<--` to assign to a signal without constraining it.
        // While our constraints can only use multiplication/addition, our
        // assignments can use any operation.
        bits[i] <-- (in1 >> i) & 1;

    // Now, contrain each bit to be 0 or 1.`
        // Use `===` to enforce a rank-1 constraint (R1C) on signals.
        bits[i] * (1 - bits[i]) === 0;
        // ^--A--^   ^-----B-----^     C
        //
        // The linear combinations A, B, and C in this R1C.

    // Now, construct a sum of all the bits...
        // This `var` is going to be a linear combination.
        sum_of_bits += (2 ** i) * bits[i];
    }

    // Constrain that sum (which is a linear combination of signals) to
    // be `in`.
    sum_of_bits === in1;
    signal dummy; // https://pullanswer.com/questions/snarkjs-error-scalar-size-does-not-match-on-addition-not-multiplication
    dummy <== in1 * in1;
}

// Now we look at `SmallOdd`, a circuit which features:
//
//    * the use of components, or sub-circuits
//    * the `<==` operator, which combines `<--` and `===`.

/*
 * Enforces that `in` is an odd number less than 2 ** `b`.
 */
template SmallOdd(b) {
    signal input in;

    // Declare and intialize a sub-circuit;
    component binaryDecomposition = Num2Bits(b);

    // Use `<==` to **assign** and **constrain** simultaneously.
    binaryDecomposition.in <== in; // ?? why constrain

    // Constrain the least significant bit to be 1.
    binaryDecomposition.bits[0] === 1;
}

// Next we look at `SmallOddFactorization`, a circuit which features:
//
//    * arrays of components
//    * using helper (witness) signals to express multiple multiplications
//       * (or any iterator general computation)

/*
 * Enforces the factorization of `product` into `n` odd factors that are each
 * less than 2 ** `b`.
 */
template SmallOddFactorization(n, b) {
    signal input product;
    signal input factors[n]; // c: private 

    // Constrain each factor to be small and odd.
    // We're going to need `n` subcircuits for small-odd-ness.
    component smallOdd[n];
    for (var i = 0; i < n; i++) {
        smallOdd[i] = SmallOdd(b);
        smallOdd[i].in <== factors[i]; // ?? why contrain
        
    }

    // Now constrain the factors to multiply to the product. Since there are
    // many multiplications, we introduce helper signals to split the
    // multiplications up into R1Cs.
    signal partialProducts[n + 1];
    partialProducts[0] <== 1;
    for (var i = 0; i < n; i++) {
        partialProducts[i + 1] <== partialProducts[i] * factors[i]; // ?? why contrain
    }
    product === partialProducts[n];
}

// Finally, we set the `main` circuit for this file, which is the circuit that
// `circom` will synthesize.
// component main {public [product, factors]} = SmallOddFactorization(3, 8); // note: 3 factors each with 8 bits and is odd. 
component main = Num2Bits(4);
//component main = IsZero();
//component main = Multiplier2();
/* 
TODO
array input
component main {public [in1,in2]} = Multiplier2();

In circom, all output signals of the main component are public (and cannot be made private), 
the input signals of the main component are private if not stated otherwise using the keyword public as above. 
The rest of signals are all private and cannot be made public.
how to decide public/private consideration 

 */

/* note:
In circom, all output signals of the main component are public (and cannot be made private), 
the input signals of the main component are private if not stated otherwise using the keyword public as above. 
The rest of signals are all private and cannot be made public.
 */