import { createAccount } from "@aztec/accounts/testing";
import {
  AztecAddress,
  ContractInstanceWithAddress,
  createPXEClient,
  DeployedContract,
  EthAddress,
  Fr,
  initAztecJs,
  PXE,
} from "@aztec/aztec.js";
import { MeaningOfLifeContract } from "./artifacts/MeaningOfLife.ts";

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
  console.log(deployedContract.address);

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

  return deployedContract.address;
};

export const unconstrainedCall = async (
  pxe: PXE,
  contractAddress: AztecAddress,
  methodName: string,
  args: any[]
) => {
  let result = await pxe.viewTx(methodName, args, contractAddress);

  return result;
};