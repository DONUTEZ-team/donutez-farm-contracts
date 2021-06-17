const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  tokens: new MichelsonMap(),
  tokens_count: new MichelsonMap(),
  metadata_tmp: new MichelsonMap(),
  token_metadata_tmp: new MichelsonMap(),
  token_info_tmp: new MichelsonMap(),
};
