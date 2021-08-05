const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

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
    const metadata = {
      "": Buffer.from("tezos-storage:token", "ascii").toString("hex"),
      token: Buffer.from(
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
    };
    const tokenMetadata = {
      symbol: Buffer.from("TST").toString("hex"),
      name: Buffer.from("Test").toString("hex"),
      decimals: Buffer.from("6").toString("hex"),
      icon: Buffer.from(
        "ipfs://QmT61Sqko5vGxwcUSMTaLMfrJLhei8StBUzpAVQqfCjwzC"
      ).toString("hex"),
    };
    const operation = await factoryInstance.methods
      .default(
        totalSupply,
        [
          ["", metadata[""]],
          ["token", metadata["token"]],
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

    const storage = await factoryInstance.storage();
    const userTokensCount = await storage.tokens_count.get(alice.pkh);
    const tokens = await storage.tokens.get(alice.pkh);
    const tokenAddress = await tokens.get("1");

    strictEqual(userTokensCount.toNumber(), 2);

    const testTokenInstance = await tezos.contract.at(tokenAddress);
    const testStorage = await testTokenInstance.storage();
    const testTokenMetadata = await testStorage.token_metadata.get("0");

    strictEqual(
      await testTokenMetadata.token_info.get("name"),
      tokenMetadata["name"]
    );
    strictEqual(
      await testTokenMetadata.token_info.get("symbol"),
      tokenMetadata["symbol"]
    );
    strictEqual(
      await testTokenMetadata.token_info.get("decimals"),
      tokenMetadata["decimals"]
    );
    strictEqual(
      await testTokenMetadata.token_info.get("icon"),
      tokenMetadata["icon"]
    );
    strictEqual(testStorage.total_supply.toString(), totalSupply);
  });
});
