// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { Script, console2 } from "forge-std/Script.sol";

import { AxiomV2Addresses } from "@axiom-crypto/axiom-std/AxiomV2Addresses.sol";

import { UnsupportedAssetRefund } from "../src/UnsupportedAssetRefund.sol";

contract UnsupportedAssetRefundScript is Script {
    address public AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR;
    bytes32 _querySchema;

    function setUp() public {
        string memory artifact = vm.readFile("./app/axiom/data/compiled.json");
        _querySchema = bytes32(vm.parseJson(artifact, ".querySchema"));

        AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR = AxiomV2Addresses.axiomV2QueryMockAddress(11_155_111);
    }

    function run() public {
        vm.startBroadcast();

        new UnsupportedAssetRefund(AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR, _querySchema);

        vm.stopBroadcast();
    }
}
