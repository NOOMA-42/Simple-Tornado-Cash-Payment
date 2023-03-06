pragma circom 2.0.0;

include "./mimc.circom";

/*
 * IfThenElse sets `out` to `true_value` if `condition` is 1 and `out` to
 * `false_value` if `condition` is 0.
 *
 * It enforces that `condition` is 0 or 1.
 *
 */
template IfThenElse() {
    signal input condition;
    signal input true_value;
    signal input false_value;
    signal output out;

    // TODO
    // Hint: You will need a helper signal...
    condition * (1 - condition) === 0;

    signal intermediate <== 1;
    out <-- condition * intermediate == intermediate ? true_value : false_value;
}

/*
 * SelectiveSwitch takes two data inputs (`in0`, `in1`) and produces two ouputs.
 * If the "select" (`s`) input is 1, then it inverts the order of the inputs
 * in the ouput. If `s` is 0, then it preserves the order.
 *
 * It enforces that `s` is 0 or 1.
 */
template SelectiveSwitch() {
    signal input in0;
    signal input in1;
    signal input s;
    signal output out0;
    signal output out1;

    // TODO
    component outFirst = IfThenElse();
    outFirst.condition <== s;
    outFirst.true_value <== in1;
    outFirst.false_value <== in0;

    component outSecond = IfThenElse();
    outSecond.condition <== s;
    outSecond.true_value <== in0;
    outSecond.false_value <== in1;  
    
    out0 <== outFirst.out;
    out1 <== outSecond.out;
}

/*
 * Verifies the presence of H(`nullifier`, `nonce`) in the tree of depth
 * `depth`, summarized by `digest`.
 * This presence is witnessed by a Merkle proof provided as
 * the additional inputs `sibling` and `direction`, 
 * which have the following meaning:
 *   sibling[i]: the sibling of the node on the path to this coin
 *               at the i'th level from the bottom.
 *   direction[i]: "0" or "1" indicating whether that sibling is on the left.
 *       The "sibling" hashes correspond directly to the siblings in the
 *       SparseMerkleTree path.
 *       The "direction" keys the boolean directions from the SparseMerkleTree
 *       path, casted to string-represented integers ("0" or "1").
 */
template Spend(depth) {
    signal input digest;
    signal input nullifier;
    signal input nonce;
    signal input sibling[depth];
    signal input direction[depth];
    log("test input: ", sibling[1]);
    // TODO
    component mimc[depth+1];
    component selectiveSwitcher[depth];
    signal output hash[depth+1]; // https://github.com/iden3/snarkjs/issues/116; is it susceptible to attack? and why

    mimc[0] = Mimc2();
    mimc[0].in0 <== nullifier;
    mimc[0].in1 <== nonce;
    hash[0] <== mimc[0].out;
    for (var i = 0; i < depth; i++){
        selectiveSwitcher[i] = SelectiveSwitch();
        selectiveSwitcher[i].in0 <== hash[i];
        log(i);
        log("sibling on the left", direction[i]);
        log("original value: ", hash[i]);
        log("sibling: ", sibling[i]);
        log("left: ", selectiveSwitcher[i].in0);
        selectiveSwitcher[i].in1 <== sibling[i];
        selectiveSwitcher[i].s <== direction[i];
        mimc[i+1] = Mimc2();
        mimc[i+1].in0 <== selectiveSwitcher[i].out0;
        log("left", selectiveSwitcher[i].out0);
        log(" ");
        mimc[i+1].in1 <== selectiveSwitcher[i].out1;
        hash[i+1] <== mimc[i+1].out;
    }
    log(hash[4]);
    log(depth);
    log(digest);
    hash[depth] === digest;
}