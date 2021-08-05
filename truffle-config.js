require("dotenv").config();
require("ts-node").register({
  files: true,
});

const { alice, dev } = require("./scripts/sandbox/accounts");

module.exports = {
  contracts_directory: "./contracts/main",

  networks: {
    development: {
      host: "http://localhost",
      port: 8732,
      network_id: "*",
      secretKey: alice.sk,
      type: "tezos",
    },
    granadanet: {
      rpc: "https://granadanet.smartpy.io",
      port: 443,
      network_id: "*",
      secretKey: dev.sk,
      type: "tezos",
    },
    mainnet: {
      host: "https://mainnet.smartpy.io",
      port: 443,
      network_id: "*",
      secretKey: dev.sk,
      type: "tezos",
    },
  },

  mocha: {
    timeout: 5000000,
  },
};
