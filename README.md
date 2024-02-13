# Asset Refund (using Axiom Client SDK)

This example allows users to claim a refund of UNI token sent to the specified address (currently [0xe534b1d79cB4C8e11bEB93f00184a12bd85a63fD](https://sepolia.etherscan.io/address/0xe534b1d79cB4C8e11bEB93f00184a12bd85a63fD)) on the Sepolia testnet. Users utilize a data-fetching layer on top of Axiom to prove that their account matches some parameters before submitting a Query. In this case, the parameters are that the user has sent UNI to the specified address. The entire amount in UNI is refunded, and a refund can be claimed exactly once for each transaction. Currently, only the most recent transaction can be refunded.

This example was created by writing a client circuit with the [Axiom Client SDK](https://github.com/axiom-crypto/axiom-sdk-client) and using it to generate Axiom queries inside a webapp using [Axiom SDK React Components](https://www.npmjs.com/package/@axiom-crypto/react).

## dApp

[`/app`](./app) is a full Next.js 14 implementation of the Asset Refund dApp. You will need to fill in an `.env.local` file in that folder for the Next.js app to run.

## Axiom Circuit

The Axiom client circuit code and supporting files are is located in [`./app/axiom`](./app/axiom).
