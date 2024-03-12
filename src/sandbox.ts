import { createAccount } from "@aztec/accounts/testing";
import { createPXEClient, initAztecJs, PXE } from "@aztec/aztec.js";
import { MeaningOfLifeContract } from "./artifacts/MeaningOfLife";

export const initSandbox = async () => {
    const SANDBOX_URL = "http://localhost:8080";
    const pxe = createPXEClient(SANDBOX_URL);
    await initAztecJs();
    return pxe;
};

export const deployContract = async (pxe: PXE) => {
    let deployer = await createAccount(pxe);
    let deployedContract = await MeaningOfLifeContract.deploy(deployer).send().deployed();
    console.log(deployedContract);
    return deployedContract.address;
};
  