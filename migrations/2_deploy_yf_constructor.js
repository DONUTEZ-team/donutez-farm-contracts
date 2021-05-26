const YFConstructor = artifacts.require("YFConstructor");

const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

const { confirmOperation } = require("../test/helpers/confirmation");
const { addToOutput } = require("./utils/add_to_output");
const { dev, alice } = require("../scripts/sandbox/accounts");

const YFConstructorStorage = require("../storage/YFConstructor");

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
    code: JSON.parse(YFConstructor.michelson),
    storage: YFConstructorStorage,
  });

  await confirmOperation(tezos, operation.hash);

  YFConstructor.address = operation.contractAddress;

  console.log("YFConstructor: ", operation.contractAddress);

  addToOutput("YFConstructor", operation.contractAddress, "APPEND");
};
