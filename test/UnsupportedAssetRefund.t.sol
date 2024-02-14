// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@axiom-crypto/axiom-std/AxiomTest.sol";

import { IERC20 } from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import { UnsupportedAssetRefund } from "../src/UnsupportedAssetRefund.sol";

uint256 constant MAX_INT = 2 ** 256 - 1;

contract UnsupportedAssetRefundTest is AxiomTest {
    using Axiom for Query;

    UnsupportedAssetRefund assetRefund;

    struct AxiomInput {
        uint64 numClaims;
        uint64[] blockNumbers;
        uint64[] txIdxs;
        uint64[] logIdxs;
    }

    AxiomInput public input;
    bytes32 public querySchema;

    address public constant UNI_ADDR = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public constant UNI_SENDER_ADDR = 0x84F722ec6713E2e645576387a3Cb28cfF6126ac4;
    address public constant UNI_RECEIVER_ADDR = 0xe534b1d79cB4C8e11bEB93f00184a12bd85a63fD;

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

    function test_refund() public {
        vm.prank(UNI_RECEIVER_ADDR);
        IERC20(UNI_ADDR).approve(address(assetRefund), MAX_INT);

        deal(UNI_ADDR, UNI_RECEIVER_ADDR, 100 * 1e18);

        Query memory q = query(querySchema, abi.encode(input), address(assetRefund));

        q.send();
        bytes32[] memory results = q.prankFulfill(UNI_SENDER_ADDR);
    }
}
