// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "@axiom-crypto/v2-periphery/interfaces/client/IAxiomV2Client.sol";

interface IUnsupportedAssetRefund is IAxiomV2Client {
    event ClaimRefund(address indexed user, uint256 indexed queryId, uint256 transferValue, bytes32[] axiomResults);
    event AxiomCallbackQuerySchemaUpdated(bytes32 axiomCallbackQuerySchema);

    function updateCallbackQuerySchema(bytes32 _axiomCallbackQuerySchema) external;
}
