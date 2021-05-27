const TokenFactoryFA12 = artifacts.require("TokenFactoryFA12");

const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

const { confirmOperation } = require("../test/helpers/confirmation");
const { addToOutput } = require("./utils/add_to_output");
const { dev, alice } = require("../scripts/sandbox/accounts");

const tokenFactoryStorage = require("../storage/TokenFactory");

module.exports = async (deployer, network, accounts) => {
  tezos = new TezosToolkit(tezos.rpc.url);
  tezos.setProvider({
    config: {
      confirmationPollingTimeoutSecond:
        process.env.CONFIRMATION_POLLING_TIMEOUT_SECOND,
    },
    signer: ["development"].includes(network)
      ? await InMemorySigner.fromSecretKey(alice.sk)
      : await InMemorySigner.fromSecretKey(dev.sk),
  });

  const operation = await tezos.contract.originate({
    code: JSON.parse(TokenFactoryFA12.michelson),
    storage: tokenFactoryStorage,
  });

  await confirmOperation(tezos, operation.hash);

  TokenFactoryFA12.address = operation.contractAddress;

  console.log("TokenFactoryFA12: ", operation.contractAddress);

  addToOutput("TokenFactoryFA12", operation.contractAddress, "WRITE");
};
