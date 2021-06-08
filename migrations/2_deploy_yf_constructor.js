const YFConstructor = artifacts.require("YFConstructor");
const TokenFactoryFA12 = artifacts.require("TokenFactoryFA12");

const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");
const { MichelsonMap } = require("@taquito/michelson-encoder");

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

  const tokenFactoryFA12Instance = await tezos.contract.at(
    TokenFactoryFA12.address
  );
  const totalSupply = "100000000"; // 100 DTZ
  const metadata = MichelsonMap.fromLiteral({
    "": Buffer("tezos-storage:dtz", "ascii").toString("hex"),
    dtz: Buffer(
      JSON.stringify({
        version: "v1.0.0",
        description: "Donutez Token",
        authors: ["<donutez_team@gmail.com>"],
        source: {
          tools: ["Ligo", "Flextesa"],
          location: "https://ligolang.org/",
        },
        interfaces: ["TZIP-7", "TZIP-16"],
        errors: [],
        views: [],
      }),
      "ascii"
    ).toString("hex"),
  });
  const tokenInfo = MichelsonMap.fromLiteral({
    symbol: Buffer.from("DTZ").toString("hex"),
    name: Buffer.from("Donutez").toString("hex"),
    decimals: Buffer.from("6").toString("hex"),
    icon: Buffer.from(
      "ipfs://QmX6Tq7RRErP5B3GGnypHvzW6ZFA72Ug9ciaznS3a4BQQP"
    ).toString("hex"),
  });

  let operation = await tokenFactoryFA12Instance.methods
    .default(totalSupply, metadata, tokenInfo)
    .send();

  await confirmOperation(tezos, operation.hash);

  operation = await tezos.contract.originate({
    code: JSON.parse(YFConstructor.michelson),
    storage: YFConstructorStorage,
  });

  await confirmOperation(tezos, operation.hash);

  YFConstructor.address = operation.contractAddress;

  console.log("YFConstructor: ", operation.contractAddress);

  addToOutput("YFConstructor", operation.contractAddress, "APPEND");
};
