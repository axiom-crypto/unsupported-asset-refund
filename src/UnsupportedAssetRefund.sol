// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IERC20 } from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin-contracts/access/Ownable.sol";

import { AxiomV2Client } from "@axiom-crypto/v2-periphery/client/AxiomV2Client.sol";
import { IUnsupportedAssetRefund } from "./interfaces/IUnsupportedAssetRefund.sol";

contract UnsupportedAssetRefund is IUnsupportedAssetRefund, AxiomV2Client, Ownable {
    bytes32 public constant TRANSFER_SCHEMA = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    uint64 public immutable callbackSourceChainId;
    bytes32 public axiomCallbackQuerySchema;

    /// @dev `lastClaimedId[tokenContractAddress][from][to]` stores the most recently used claimId
    ///      for a transfer of the ERC-20 at `tokenContractAddress` from `from` to `to`.
    mapping(address => mapping(address => mapping(address => uint256))) lastClaimedId;

    constructor(address _axiomV2QueryAddress, uint64 _callbackSourceChainId, bytes32 _axiomCallbackQuerySchema)
        AxiomV2Client(_axiomV2QueryAddress)
    {
        callbackSourceChainId = _callbackSourceChainId;
        axiomCallbackQuerySchema = _axiomCallbackQuerySchema;
    }

    function updateCallbackQuerySchema(bytes32 _axiomCallbackQuerySchema) public onlyOwner {
        axiomCallbackQuerySchema = _axiomCallbackQuerySchema;
        emit AxiomCallbackQuerySchemaUpdated(_axiomCallbackQuerySchema);
    }

    function _axiomV2Callback(
        uint64, /* sourceChainId */
        address callerAddr,
        bytes32, /* querySchema */
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata /* extraData */
    ) internal virtual override {
        address fromAddress = address(uint160(uint256(axiomResults[0])));
        address toAddress = address(uint160(uint256(axiomResults[1])));
        uint256 transferValue = uint256(axiomResults[2]);
        address tokenContractAddress = address(uint160(uint256(axiomResults[3])));
        uint256 endClaimId = uint256(axiomResults[4]);
        uint256 startClaimId = uint256(axiomResults[5]);

        require(fromAddress == callerAddr, "UnsupportedAssetRefund: Invalid fromAddress");
        require(
            lastClaimedId[tokenContractAddress][fromAddress][toAddress] < startClaimId,
            "UnsupportedAssetRefund: Already claimed"
        );

        lastClaimedId[tokenContractAddress][fromAddress][toAddress] = endClaimId;
        emit ClaimRefund(callerAddr, queryId, transferValue, axiomResults);

        require(IERC20(tokenContractAddress).transferFrom(toAddress, fromAddress, transferValue), "Refund failed");
    }

    function _validateAxiomV2Call(
        AxiomCallbackType, /* callbackType */
        uint64 sourceChainId,
        address, /* caller  */
        bytes32 querySchema,
        uint256, /* queryId */
        bytes calldata /* extraData */
    ) internal virtual override {
        require(sourceChainId == callbackSourceChainId, "UnsupportedAssetRefund: sourceChainId mismatch");
        require(querySchema == axiomCallbackQuerySchema, "UnsupportedAssetRefund: querySchema mismatch");
    }
}
