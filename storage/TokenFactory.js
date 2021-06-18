const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  tokens: new MichelsonMap(),
  tokens_count: new MichelsonMap(),
  tmp1: new MichelsonMap(),
  tmp2: new MichelsonMap(),
  tmp3: new MichelsonMap(),
  tmp4: new MichelsonMap(),
  tmp5: new MichelsonMap(),
};
