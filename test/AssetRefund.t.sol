// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@axiom-crypto/axiom-std/AxiomTest.sol";

import { AssetRefund } from "../src/AssetRefund.sol";

import { MockERC20 } from "./MockERC20.sol";

contract AssetRefundTest is AxiomTest {
    using Axiom for Query;

    struct AxiomInput {
        uint64 blockNumber;
        uint256 txIdx;
        uint256 logIdx;
        address senderAddress;
        uint256 expectedAmount;
    }

    address public constant UNI_SENDER_ADDR = 0x84F722ec6713E2e645576387a3Cb28cfF6126ac4;
    AssetRefund _assetRefund;

    AxiomInput public input;
    bytes32 public querySchema;

    function setUp() public {
        _createSelectForkAndSetupAxiom("sepolia", 5_103_100);

        input = AxiomInput({
            blockNumber: 5_141_305,
            txIdx: 44,
            logIdx: 0,
            senderAddress: address(0x84F722ec6713E2e645576387a3Cb28cfF6126ac4),
            expectedAmount: 1e18
        });
        querySchema = axiomVm.readCircuit("app/axiom/refundEvent.circuit.ts");

        _assetRefund = new AssetRefund(
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

        // Approve your AssetRefund contract to spend UNI tokens
        uniToken.approve(address(_assetRefund), initialBalance);

        // Check the allowance
        uint256 allowance = uniToken.allowance(testAddress, address(_assetRefund));
        assertEq(allowance, initialBalance, "Allowance was not set correctly");
    }

    function test_refund() public {
        Query memory q = query(querySchema, abi.encode(input), address(_assetRefund));

        q.send();
        bytes32[] memory results = q.prankFulfill();
    }
}
