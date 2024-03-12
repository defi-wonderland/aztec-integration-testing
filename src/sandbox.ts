import { createPXEClient, initAztecJs } from "@aztec/aztec.js";

export const initSandbox = async () => {
    const SANDBOX_URL = "http://localhost:8080";
    const pxe = createPXEClient(SANDBOX_URL);
    await initAztecJs();
    return pxe;
};