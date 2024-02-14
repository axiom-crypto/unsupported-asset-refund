# Unsupported Asset Refund

Unsupported Asset Refund (UAR) allows the owner of any address on Ethereum (EOA or smart contract) to offer self-serve refunds for a set of ERC-20 tokens sent to that address which are designated as **unsupported**. To opt in to the UAR system for a specific ERC-20, contract owners simply give an allowance to UAR, which they can revoke at any time.

Users who have accidentally sent unsupported ERC-20 tokens to an address can claim a refund by proving their previous transfers to UAR with Axiom. UAR will validate these transfers and issue a refund to users, all without any intervention from the original contract owner. UAR ensures that a refund can be claimed exactly once for each transaction.

## Development

To set up the development environment, run:

```bash
forge install
npm install   # or `yarn install` or `pnpm install`
```
