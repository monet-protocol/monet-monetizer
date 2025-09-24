import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

import { checkAddressValid, parseToConfigData } from "../utils";
import { readFileSync } from "fs";

import { IERC20Abi } from "../abis/IERC20";
import { getContractAddress } from "viem";

const contractName = "Savings";

const token = "USDmo";
const initialDivider = "1";

export default deployScript(
  async ({ namedAccounts, network, deployViaProxy, viem }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \nDeployer: ${deployer} \nDeploying : ${contractName}`);

    const config = parseToConfigData(
      JSON.parse(readFileSync(`./deploy/config/${network.name.toLowerCase()}/config.json`).toString()),
    );

    const accessManager = checkAddressValid(config.accessManager, "Invalid AccessManager address");
    const tokenP = checkAddressValid(
      config.tokens[token.toLowerCase() as keyof typeof config.tokens],
      "Invalid tokenP address",
    );
    const savingsConfig = config.savings[token.toLowerCase() as keyof typeof config.savings];

    // const nonce = await viem.publicClient.getTransactionCount({
    //   address: deployer,
    // });

    // const futureAddress0 = getContractAddress({
    //   from: deployer,
    //   nonce: BigInt(nonce + 0),
    // });
    // const futureAddress1 = getContractAddress({
    //   from: deployer,
    //   nonce: BigInt(nonce + 1),
    // });
    // const futureAddress2 = getContractAddress({
    //   from: deployer,
    //   nonce: BigInt(nonce + 2),
    // });
    // const futureAddress3 = getContractAddress({
    //   from: deployer,
    //   nonce: BigInt(nonce + 3),
    // });
    // const futureAddress4 = getContractAddress({
    //   from: deployer,
    //   nonce: BigInt(nonce + 4),
    // });
    // console.log({ futureAddress0, futureAddress1, futureAddress2, futureAddress3, futureAddress4 });
    // const allowance = (await viem.publicClient.readContract({
    //   abi: IERC20Abi,
    //   address: tokenP,
    //   functionName: "allowance",
    //   args: [deployer, futureAddress2],
    // })) as bigint;

    // console.log("before approve", { futureAddress1, allowance });
    // if (allowance < BigInt(1e18)) {
    console.log("Approving allowance for future address of 1e18");
    const { request } = await viem.publicClient.simulateContract({
      account: deployer,
      address: tokenP,
      abi: IERC20Abi,
      functionName: "approve",
      args: ["0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496", BigInt(1e18)],
    });
    const hash = await viem.walletClient.writeContract(request);
    await viem.publicClient.waitForTransactionReceipt({ hash });
    // }

    // console.log("after approve", { futureAddress1, allowance });

    const savings = await deployViaProxy(
      `${contractName}_${token}`,
      {
        account: deployer,
        artifact: artifacts.SavingsNameable,
      },
      {
        proxyContract: "UUPS",
        execute: {
          methodName: "initialize",
          args: [accessManager, tokenP, savingsConfig.name, savingsConfig.symbol, initialDivider],
        },
        linkedData: {
          args: [accessManager, tokenP, savingsConfig.name, savingsConfig.symbol, initialDivider],
        },
      },
    );

    console.log(`Deployed ${contractName}_${token}, network: ${network.name}, address: ${savings.address}`);
  },
  {
    tags: [contractName],
  },
);
