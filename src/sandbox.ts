import { createAccount } from "@aztec/accounts/testing";
import {
  AztecAddress,
  ContractFunctionInteraction,
  ContractInstanceWithAddress,
  createPXEClient,
  DeployedContract,
  encodeArguments,
  EthAddress,
  ExtendedContractData,
  Fr,
  FunctionArtifact,
  FunctionSelector,
  initAztecJs,
  PackedArguments,
  PXE,
  Tx,
  TxExecutionRequest,
  TxHash,
} from "@aztec/aztec.js";

import { FunctionData, TxContext } from "@aztec/circuits.js";
import { computeVarArgsHash } from "@aztec/circuits.js/hash";

import { MeaningOfLifeContract } from "./artifacts/MeaningOfLife.ts";

let selectorsResolved = new Map<string, string>();
let contractClassId: Fr = new Fr(0);

export const initSandbox = async () => {
  const SANDBOX_URL = "http://localhost:8080";
  const pxe = createPXEClient(SANDBOX_URL);
  await initAztecJs();

  return pxe;
};

export const deployContract = async (pxe: PXE) => {
  let deployer = await createAccount(pxe);
  let deployedContract = await MeaningOfLifeContract.deploy(deployer)
    .send()
    .deployed();

  let instance: ContractInstanceWithAddress = deployedContract.instance;
  contractClassId = instance.contractClassId;

  let deployedContractInstance: DeployedContract = {
    artifact: MeaningOfLifeContract.artifact,
    instance,
  };

  await pxe.addContracts([deployedContractInstance]);

  // Resolve the function selectors and store them
  MeaningOfLifeContract.artifact.functions.forEach((f: FunctionArtifact) => {
    selectorsResolved.set(
      FunctionSelector.fromNameAndParameters(f.name, f.parameters).toString(),
      f.name
    );
  });

  return deployedContract.address;
};

// todo: add notes -> how to catch them? Or passed as args (cumbersome++)
export const internalCall = async (
  pxe: PXE,
  contractAddress: AztecAddress,
  functionSelector: FunctionSelector,
  args: Fr[]
) => {
  const functionName = selectorsResolved.get(functionSelector.toString());

  const functionArtifact = MeaningOfLifeContract.artifact.functions.find(
    (f: FunctionArtifact) => f.name === functionName
  );

  if (!functionArtifact) {
    throw new Error("Function not found");
  }

  const functionData = new FunctionData(functionSelector, false, true, false);

  // todo: arg type should be fixed here (we pass arrays even for single fields)
  const packedArguments = PackedArguments.fromArgs(
    encodeArguments(functionArtifact, [args[0]])
  );

  const txContext = TxContext.empty();
  txContext.contractDeploymentData.contractClassId = contractClassId;

  // todo: mocking?
  const txExecutionRequest = TxExecutionRequest.from({
    origin: contractAddress,
    argsHash: computeVarArgsHash([args[0]]),
    functionData,
    txContext,
    packedArguments: [packedArguments],
    authWitnesses: [],
  });

  let tx: Tx = await pxe.simulateTx(txExecutionRequest, false);

  await pxe.sendTx(tx);
};

export const unconstrainedCall = async (
  pxe: PXE,
  contractAddress: AztecAddress,
  functionSelector: FunctionSelector,
  args: any[]
) => {
  // reverse lookup the fn selector
  let methodName = selectorsResolved.get(functionSelector.toString());

  if (!methodName) {
    throw new Error("Function not found");
  }

  // make the unconstrained call
  let result = await pxe.viewTx(methodName, args, contractAddress);

  return result;
};