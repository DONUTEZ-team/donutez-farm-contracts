const YFConstructor = artifacts.require("YFConstructor");
const TokenFactoryFA12 = artifacts.require("TokenFactoryFA12");

const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

const { confirmOperation } = require("../test/helpers/confirmation");
const { addToOutput } = require("./utils/add_to_output");
const { dev, alice } = require("../scripts/sandbox/accounts");

const YFConstructorStorage = require("../storage/YFConstructor");

module.exports = async (deployer, network, accounts) => {
  const signer = ["development"].includes(network) ? alice.pkh : dev.pkh;

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
  const metadata = {
    "": Buffer.from("tezos-storage:dtz", "ascii").toString("hex"),
    dtz: Buffer.from(
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
  };
  const tokenMetadata = {
    symbol: Buffer.from("DTZ").toString("hex"),
    name: Buffer.from("Donutez").toString("hex"),
    decimals: Buffer.from("6").toString("hex"),
    icon: Buffer.from(
      "ipfs://QmT61Sqko5vGxwcUSMTaLMfrJLhei8StBUzpAVQqfCjwzC"
    ).toString("hex"),
  };

  let operation = await tokenFactoryFA12Instance.methods
    .default(
      totalSupply,
      [
        ["", metadata[""]],
        ["dtz", metadata["dtz"]],
      ],
      [
        [
          0,
          [
            ["symbol", tokenMetadata["symbol"]],
            ["name", tokenMetadata["name"]],
            ["decimals", tokenMetadata["decimals"]],
            ["icon", tokenMetadata["icon"]],
          ],
        ],
      ]
    )
    .send();

  await confirmOperation(tezos, operation.hash);

  const tokenFactoryFA12Storage = await tokenFactoryFA12Instance.storage();
  const tokensByDeployer = await tokenFactoryFA12Storage.tokens.get(signer);
  const dtzTokenAddress = await tokensByDeployer.get("0");

  addToOutput("DTZ token", dtzTokenAddress, "APPEND");

  console.log("DTZ token: ", dtzTokenAddress);

  YFConstructorStorage.dtz_token = dtzTokenAddress;

  operation = await tezos.contract.originate({
    code: JSON.parse(YFConstructor.michelson),
    storage: YFConstructorStorage,
  });

  await confirmOperation(tezos, operation.hash);

  YFConstructor.address = operation.contractAddress;

  addToOutput("YFConstructor", YFConstructor.address, "APPEND");

  console.log("YFConstructor: ", YFConstructor.address);
};
