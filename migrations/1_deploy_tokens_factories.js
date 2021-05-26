const FactoryFA12 = artifacts.require("FactoryFA12");
const FactoryFA2 = artifacts.require("FactoryFA2");

const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

const { confirmOperation } = require("../test/helpers/confirmation");
const { addToOutput } = require("./utils/add_to_output");
const { dev, alice } = require("../scripts/sandbox/accounts");

const FA12FactoryStorage = require("../storage/FA12Factory");
const FA2FactoryStorage = require("../storage/FA2Factory");

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

  let operation = await tezos.contract.originate({
    code: JSON.parse(FactoryFA12.michelson),
    storage: FA12FactoryStorage,
  });

  await confirmOperation(tezos, operation.hash);

  FactoryFA12.address = operation.contractAddress;

  console.log("FactoryFA12: ", operation.contractAddress);

  addToOutput("FactoryFA12", operation.contractAddress, "WRITE");

  operation = await tezos.contract.originate({
    code: JSON.parse(FactoryFA2.michelson),
    storage: FA2FactoryStorage,
  });

  await confirmOperation(tezos, operation.hash);

  FactoryFA2.address = operation.contractAddress;

  console.log("FactoryFA2: ", operation.contractAddress);

  addToOutput("FactoryFA2", operation.contractAddress, "APPEND");
};
