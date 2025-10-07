export const getRpcURL = (network: string): string => {
  switch (network) {
    case "edennetTestnet": {
      return "https://ev-reth-eden-testnet.binarybuilders.services:8545/";
    }
    default: {
      throw new Error(`${network} Network RPC not configured`);
    }
  }
};
