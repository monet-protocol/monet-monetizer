export const getRpcURL = (network: string): string => {
  switch (network) {
    case "edennetTestnet": {
      // return "http://rpc-evreth-sequencer-edennet-1-testnet.binary.builders:8080";
      return "https://eden-rpc-proxy.up.railway.app/rpc";
    }
    default: {
      throw new Error(`${network} Network RPC not configured`);
    }
  }
};
