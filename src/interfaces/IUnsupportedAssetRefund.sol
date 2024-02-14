// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "@axiom-crypto/v2-periphery/interfaces/client/IAxiomV2Client.sol";

interface IUnsupportedAssetRefund is IAxiomV2Client {
    /// @notice Emitted when the query schema associated with the Axiom query is updated
    /// @param axiomCallbackQuerySchema the new query schema
    event AxiomCallbackQuerySchemaUpdated(bytes32 axiomCallbackQuerySchema);

    /// @notice Emitted when a refund is claimed
    /// @param token the address of the ERC-20 token
    /// @param refundee the address of the refundee
    /// @param refunder the address of the refunder
    /// @param value the amount of the refund
    event RefundClaimed(address indexed token, address indexed refundee, address indexed refunder, uint256 value);

    /// @notice Error for when the caller address claiming the refund does not match the from address
    error FromAddressDoesNotMatchCaller();

    /// @notice Error for when the claimId range is invalid
    error ClaimIdRangeInvalid();

    /// @notice Error for when the refund transfer failed
    error RefundTransferFailed();

    /// @notice Error for when the allowance is too small
    error AllowanceTooSmall();

    /// @notice Error for when the source chain ID does not match
    error SourceChainIdDoesNotMatch();

    /// @notice Error for when the query schema does not match
    error QuerySchemaDoesNotMatch();

    /// @notice Update the query schema associated with the Axiom query
    /// @param _axiomCallbackQuerySchema the new query schema
    function updateCallbackQuerySchema(bytes32 _axiomCallbackQuerySchema) external;
}
