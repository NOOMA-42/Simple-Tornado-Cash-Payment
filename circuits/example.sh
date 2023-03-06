#!/bin/bash
circom example.circom --inspect --wasm --r1cs --sym
echo 'snarkjs r1cs print example.r1cs example.sym'
cd example_js
node generate_witness.js example.wasm ../input.json ../witness.wtns
cd ..
snarkjs groth16 setup example.r1cs powersOfTau28_hez_final_12.ptau example_0000.zkey
snarkjs zkey export verificationkey example_0000.zkey verification_key.json
snarkjs r1cs export json example.r1cs example.r1cs.json
snarkjs zkey verify example.r1cs powersOfTau28_hez_final_12.ptau example_0000.zkey
snarkjs groth16 prove example_0000.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json