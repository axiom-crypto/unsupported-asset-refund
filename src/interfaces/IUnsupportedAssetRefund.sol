// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "@axiom-crypto/v2-periphery/interfaces/client/IAxiomV2Client.sol";

interface IUnsupportedAssetRefund is IAxiomV2Client {
    event AxiomCallbackQuerySchemaUpdated(bytes32 axiomCallbackQuerySchema);

    event RefundClaimed(address indexed token, address indexed refundee, address indexed refunder, uint256 value);

    error FromAddressDoesNotMatchCaller();

    error ClaimIdRangeInvalid();

    error RefundTransferFailed();

    error AllowanceTooSmall();

    error SourceChainIdDoesNotMatch();

    error QuerySchemaDoesNotMatch();

    function updateCallbackQuerySchema(bytes32 _axiomCallbackQuerySchema) external;
}
