const chai = require("chai");
const path = require("path");
const fs = require('fs');
const snarkjs = require("snarkjs");
const bigInt = require("big-integer");
const wasm_tester = require("./../index").wasm;

(async () => {
    circuit = await wasm_tester(
            path.join(__dirname, "circuits", "spend4.circom"));
    const inPath = path.join(
        __dirname, "compute_spend_inputs", `out1.txt`)
    const input = JSON.parse(fs.readFileSync(inPath, { encoding: 'utf8' }));
    const witness = circuit.calculateWitness(input);
    
})();
