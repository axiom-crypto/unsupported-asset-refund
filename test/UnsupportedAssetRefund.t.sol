// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@axiom-crypto/axiom-std/AxiomTest.sol";

import { UnsupportedAssetRefund } from "../src/UnsupportedAssetRefund.sol";

import { MockERC20 } from "./MockERC20.sol";

contract UnsupportedAssetRefundTest is AxiomTest {
    using Axiom for Query;

    struct AxiomInput {
        uint64 numClaims;
        uint64[] blockNumbers;
        uint64[] txIdxs;
        uint64[] logIdxs;
    }

    address public constant UNI_SENDER_ADDR = 0x84F722ec6713E2e645576387a3Cb28cfF6126ac4;
    UnsupportedAssetRefund assetRefund;

    AxiomInput public input;
    bytes32 public querySchema;

    function setUp() public {
        _createSelectForkAndSetupAxiom("sepolia", 5_103_100);

        uint64[] memory blockNumbers = new uint64[](10);
        uint64[] memory txIdxs = new uint64[](10);
        uint64[] memory logIdxs = new uint64[](10);
        blockNumbers[0] = 5_141_305;
        txIdxs[0] = 44;
        logIdxs[0] = 0;
        for (uint256 idx = 1; idx < 10; idx++) {
            blockNumbers[idx] = 5_141_305;
            txIdxs[idx] = 44;
            logIdxs[idx] = 0;
        }
        input = AxiomInput({ numClaims: 1, blockNumbers: blockNumbers, txIdxs: txIdxs, logIdxs: logIdxs });
        querySchema = axiomVm.readCircuit("app/axiom/unsupportedAssetRefund.circuit.ts");

        assetRefund = new UnsupportedAssetRefund(
            axiomV2QueryAddress,
            uint64(block.chainid),
            querySchema
        );
    }

    function testAssetRefundCanSpendUNI() public {
        // Deploy Mock UNI token and allocate tokens to a test address
        MockERC20 uniToken = new MockERC20("Uniswap Token", "UNI");
        address testAddress = address(this); // or any other address you control
        uint256 initialBalance = 1e18; // 1 UNI token for simplicity
        uniToken.mint(testAddress, initialBalance);

        // Approve your UnsupportedAssetRefund contract to spend UNI tokens
        uniToken.approve(address(assetRefund), initialBalance);

        // Check the allowance
        uint256 allowance = uniToken.allowance(testAddress, address(assetRefund));
        assertEq(allowance, initialBalance, "Allowance was not set correctly");
    }

    function test_refund() public {
        Query memory q = query(querySchema, abi.encode(input), address(assetRefund));

        q.send();
        bytes32[] memory results = q.prankFulfill(UNI_SENDER_ADDR);
    }
}
