const chai = require("chai");
const path = require("path");
const wasm_tester = require("./../index").wasm;

chai.should();
var expect = chai.expect;

describe("IfThenElse", () => {
    var circuit;

    before(async () => {
        circuit = await wasm_tester(
                path.join(__dirname, "circuits", "if_then_else.circom"));
    });

    it("should give `false_value` when `condition` = 0", async () => {
        const input = {
            "condition": "0",
            "false_value": "10",
            "true_value": "11",
        };
        const witness = await circuit.calculateWitness(input);
        expect(witness[1]).to.equal(10n);
        circuit.checkConstraints(witness);
    });

    it("should give `true_value` when `condition` = 1", async () => {
        const input = {
            "condition": "1",
            "false_value": "10",
            "true_value": "11",
        };
        const witness = await circuit.calculateWitness(input);
        expect(witness[1]).to.equal(11n);
        circuit.checkConstraints(witness);
    });

    it("should enforce that s in {0, 1}", async () => {
        const input = {
            "condition": "2",
            "false_value": "10",
            "true_value": "11",
        };
        try {
            await circuit.calculateWitness(input);
        } catch (error) {
            expect(error).to.be.an('error');
        };
    });
});

