const chai = require("chai");
const path = require("path");
const snarkjs = require("snarkjs");
const bigInt = require("big-integer");
const wasm_tester = require("./../index").wasm;

chai.should();
var expect = chai.expect;

describe("SelectiveSwitch", () => {
    var circuit;

    before(async () => {
        circuit = await wasm_tester(
                path.join(__dirname, "circuits", "selective_switch.circom"));
    });

    it("should not switch when s = 0", async () => {
        const input = {
            "s": "0",
            "in0": "10",
            "in1": "11",
        };
        const witness = await circuit.calculateWitness(input);
        expect(witness[1]).to.equal(10n);
        expect(witness[2]).to.equal(11n);
    });

    it("should switch when s = 1", async () => {
        const input = {
            "s": "1",
            "in0": "10",
            "in1": "11",
        };
        const witness = await circuit.calculateWitness(input);
        expect(witness[1]).to.equal(11n);
        expect(witness[2]).to.equal(10n);
    });

    it("should enforce that s in {0, 1}", async () => {
        const input = {
            "s": "2",
            "in0": "10",
            "in1": "11",
        };
        try {
            await circuit.calculateWitness(input);
        } catch (error) {
            expect(error).to.be.an('error');
        };
    });
});

