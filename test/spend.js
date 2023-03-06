const chai = require("chai");
const path = require("path");
const fs = require('fs');
const snarkjs = require("snarkjs");
const wasm_tester = require("./../index").wasm;

chai.should();
var expect = chai.expect;

describe("Spend", () => {

    const tests = [
        { id: 0, depth: 0 },
        { id: 1, depth: 4 },
        { id: 2, depth: 25 },
    ];
    for (const { id, depth } of tests) {
        it(`witness computable for depth ${id}`, async () => {
            const circuit = await wasm_tester(
                path.join(__dirname, "circuits", `spend${depth}.circom`));
            const inPath = path.join(
                __dirname, "compute_spend_inputs", `out${id}.txt`)
            const input = JSON.parse(fs.readFileSync(inPath, { encoding: 'utf8' }));
            const witness = circuit.calculateWitness(input);
        });
        it(`witness not computable for bad input`, async () => {
            const circuit = await wasm_tester(
                path.join(__dirname, "circuits", `spend${depth}.circom`));
                const inPath = path.join(
                    __dirname, "compute_spend_inputs", `out-bad.txt`)
                    const input = JSON.parse(fs.readFileSync(inPath, { encoding: 'utf8' }));
                    try {
                        await circuit.calculateWitness(input);
                    } catch (error) {
                        expect(error).to.be.an('error');
                    };
        });
    }
});

