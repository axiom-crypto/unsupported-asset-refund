import {
  isEqual,
  isLessThan,
  checkLessThan,
  addToCallback,
  CircuitValue,
  CircuitValue256,
  constant,
  witness,
  checkEqual,
  mul,
  mulAdd,
  selectFromIdx,
  sub,
  add,
  or,
  isZero,
  getReceipt,
  getTx,
} from "@axiom-crypto/client";

const MAX_NUM_CLAIMS = 10;

/// For type safety, define the input types to your circuit here.
/// These should be the _variable_ inputs to your circuit. Constants can be hard-coded into the circuit itself.
export interface CircuitInputs {
  numClaims: CircuitValue;
  blockNumbers: CircuitValue[];
  txIdxs: CircuitValue[];
  logIdxs: CircuitValue[];
}

export const defaultInputs = {
  numClaims: 1,
  blockNumbers: [5141305, 5141305, 5141305, 5141305, 5141305, 5141305, 5141305, 5141305, 5141305, 5141305],
  txIdxs: [44, 44, 44, 44, 44, 44, 44, 44, 44, 44],
  logIdxs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
}

// The function name `circuit` is searched for by default by our Axiom CLI; if you decide to 
// change the function name, you'll also need to ensure that you also pass the Axiom CLI flag 
// `-f <circuitFunctionName>` for it to work
export const circuit = async (inputs: CircuitInputs) => {
  // Define the event schema for ERC-20 transfer
  // Transfer(address indexed from, address indexed to, uint256 value)
  const eventSchema =
    "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef";

  // Check that the number of claims is valid
  if (inputs.blockNumbers.length !== MAX_NUM_CLAIMS || inputs.txIdxs.length !== MAX_NUM_CLAIMS || inputs.logIdxs.length !== MAX_NUM_CLAIMS) {
    throw new Error("blockNumbers or txIdxs or logIdxs does not match MAX_NUM_CLAIMS");
  }
  if (inputs.numClaims.value() > MAX_NUM_CLAIMS) {
    throw new Error("Number of claims exceeds maximum");
  }
  checkLessThan(inputs.numClaims, constant(MAX_NUM_CLAIMS + 1));
  checkLessThan(constant(0), inputs.numClaims);

  let claimIds: CircuitValue[] = [];
  let inRanges: CircuitValue[] = [];
  for (var idx = 0; idx < MAX_NUM_CLAIMS; idx++) {
    const inRange = isLessThan(constant(idx), inputs.numClaims);
    const id_1 = mulAdd(inputs.blockNumbers[idx], BigInt(2 ** 64), inputs.txIdxs[idx]);
    const id = mulAdd(id_1, BigInt(2 ** 64), inputs.logIdxs[idx]);

    inRanges.push(inRange);
    claimIds.push(mul(id, inRange));
  }

  for (let idx = 1; idx < MAX_NUM_CLAIMS; idx++) {
    const isLess = isLessThan(claimIds[idx - 1], claimIds[idx]);
    const isLessOrZero = or(isLess, isZero(claimIds[idx]));
    checkEqual(isLessOrZero, 1);
  }

  const lastClaimId = selectFromIdx(claimIds, sub(inputs.numClaims, constant(1)));;

  let totalValue: CircuitValue = constant(0);
  let tokenContractAddress: CircuitValue[] = [];
  let fromAddress: CircuitValue[] = [];
  let toAddress: CircuitValue[] = [];
  for (var idx = 0; idx < MAX_NUM_CLAIMS; idx++) {
    const isValid = inRanges[idx];

    const receipt = getReceipt(inputs.blockNumbers[idx], inputs.txIdxs[idx]);
    const receiptLog = receipt.log(inputs.logIdxs[idx]);

    // check that all receipts are emitted by the same address and to / from the same address
    const receiptAddress = await receiptLog.address();
    const transferFrom = await receiptLog.topic(1, eventSchema);
    const transferTo = await receiptLog.topic(2, eventSchema);
    const transferValue: CircuitValue = (await receiptLog.data(0, eventSchema)).toCircuitValue();

    tokenContractAddress[idx] = receiptAddress.toCircuitValue();
    fromAddress[idx] = transferFrom.toCircuitValue();
    toAddress[idx] = transferTo.toCircuitValue(); 
    checkEqual(constant(0), mul(isValid, isEqual(tokenContractAddress[0], receiptAddress.toCircuitValue())));
    checkEqual(constant(0), mul(isValid, isEqual(fromAddress[0], transferFrom.toCircuitValue())));
    checkEqual(constant(0), mul(isValid, isEqual(toAddress[0], transferTo.toCircuitValue())));

    totalValue = add(totalValue, mul(isValid, transferValue));    
  }

  addToCallback(fromAddress[0]);
  addToCallback(toAddress[0]);
  addToCallback(totalValue);
  addToCallback(tokenContractAddress[0]);
  addToCallback(claimIds[0]);
  addToCallback(lastClaimId);
};