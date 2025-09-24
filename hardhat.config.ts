import "dotenv/config";

import HardhatNodeTestRunner from "@nomicfoundation/hardhat-node-test-runner";
import HardhatViem from "@nomicfoundation/hardhat-viem";
import HardhatNetworkHelpers from "@nomicfoundation/hardhat-network-helpers";
import HardhatKeystore from "@nomicfoundation/hardhat-keystore";
import HardhatDeploy from "hardhat-deploy";

import { HardhatUserConfig } from "hardhat/types/config";

import { getRpcURL } from "./utils/getRpcURL";

const PRIVATE_KEY = process.env.PRIVATE_KEY;
if (!PRIVATE_KEY) throw new Error("PRIVATE_KEY is not set");
const accounts = [PRIVATE_KEY];

const config: HardhatUserConfig = {
  plugins: [HardhatNodeTestRunner, HardhatViem, HardhatNetworkHelpers, HardhatKeystore, HardhatDeploy],

  solidity: {
    compilers: [
      {
        version: "0.8.28",
        settings: {
          evmVersion: "cancun",
          optimizer: {
            enabled: true,
            runs: 10_000,
          },
        },
      },
    ],
  },
  networks: {
    edennetTestnet: {
      type: "http",
      url: getRpcURL("edennetTestnet"),
      accounts,
    },
  },
};

export default config;
