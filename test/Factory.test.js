const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");
const { MichelsonMap } = require("@taquito/michelson-encoder");

const { strictEqual } = require("assert");

const { confirmOperation } = require("./helpers/confirmation");

const { alice } = require("../scripts/sandbox/accounts");

const TokenFactoryFA12 = artifacts.require("TokenFactoryFA12");

contract.only("TokenFactoryFA12", async () => {
  before("setup", async () => {
    tezos = new TezosToolkit(tezos.rpc.url);
    tezos.setProvider({
      config: {
        confirmationPollingTimeoutSecond:
          process.env.CONFIRMATION_POLLING_TIMEOUT_SECOND,
      },
      signer: await InMemorySigner.fromSecretKey(alice.sk),
    });

    factoryInstance = await tezos.contract.at(TokenFactoryFA12.address);
  });

  it("deploy a new FA1.2 token", async () => {
    const totalSupply = "100000000";
    const metadata = MichelsonMap.fromLiteral({
      "": Buffer("tezos-storage:token", "ascii").toString("hex"),
      token: Buffer(
        JSON.stringify({
          version: "v1.0.0",
          description: "Test Token",
          authors: ["<test@gmail.com>"],
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
      symbol: Buffer.from("TST").toString("hex"),
      name: Buffer.from("Test").toString("hex"),
      decimals: Buffer.from("6").toString("hex"),
      icon: Buffer.from(
        "ipfs://QmX6Tq7RRErP5B3GGnypHvzW6ZFA72Ug9ciaznS3a4BQQP"
      ).toString("hex"),
    });

    let operation = await factoryInstance.methods
      .default(totalSupply, metadata, tokenInfo)
      .send();

    await confirmOperation(tezos, operation.hash);

    const storage = await factoryInstance.storage();
    const userTokensCount = await storage.tokens_count.get(alice.pkh);
    const tokens = await storage.tokens.get(alice.pkh);
    const tokenAddress = await tokens.get("1");

    strictEqual(userTokensCount.toNumber(), 2);

    console.log("Test token address: ", tokenAddress);
  });
});
