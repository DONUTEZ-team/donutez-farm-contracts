const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  owner: dev.pkh,
  tokenList: new MichelsonMap(),
};
