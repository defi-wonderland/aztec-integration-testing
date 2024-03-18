import { createAccount } from "@aztec/accounts/testing";
import {
  AztecAddress,
  ContractFunctionInteraction,
  ContractInstanceWithAddress,
  createPXEClient,
  DeployedContract,
  EthAddress,
  ExtendedContractData,
  Fr,
  FunctionArtifact,
  FunctionSelector,
  initAztecJs,
  PXE,
} from "@aztec/aztec.js";
import { MeaningOfLifeContract } from "./artifacts/MeaningOfLife.ts";

let selectorsResolved = new Map<string, string>();

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

  let instance: ContractInstanceWithAddress = {
    version: 1,
    salt: new Fr(0),
    contractClassId: new Fr(0),
    initializationHash: new Fr(0),
    portalContractAddress: new EthAddress(Buffer.allocUnsafe(20).fill("")),
    publicKeysHash: new Fr(0),
    address: deployedContract.address,
  };

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