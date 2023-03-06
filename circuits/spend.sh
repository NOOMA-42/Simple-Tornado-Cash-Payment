#!/bin/sh
depth=4
circom spend${depth}.circom --wasm --r1cs --sym
cd spend${depth}_js
node generate_witness.js spend${depth}.wasm ../input_spend${depth}.json ../witness.wtns
cd ..
snarkjs groth16 setup spend${depth}.r1cs powersOfTau28_hez_final_12.ptau spend_0000.zkey
snarkjs zkey export verificationkey spend_0000.zkey verification_key.json
snarkjs r1cs export json spend${depth}.r1cs spend${depth}.r1cs.json
snarkjs zkey verify spend${depth}.r1cs powersOfTau28_hez_final_12.ptau spend_0000.zkey
snarkjs groth16 prove spend_0000.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json