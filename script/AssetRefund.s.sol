// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { Script, console2 } from "forge-std/Script.sol";

import { UnsupportedAssetRefund } from "../src/UnsupportedAssetRefund.sol";

contract UnsupportedAssetRefundScript is Script {
    address public constant AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR = 0x83c8c0B395850bA55c830451Cfaca4F2A667a983;
    bytes32 _querySchema;

    function setUp() public {
        string memory artifact = vm.readFile("./app/axiom/data/compiled.json");
        _querySchema = bytes32(vm.parseJson(artifact, ".querySchema"));
    }

    function run() public {
        vm.startBroadcast();

        new UnsupportedAssetRefund(
            AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR,
            _querySchema
        );

        vm.stopBroadcast();
    }
}
