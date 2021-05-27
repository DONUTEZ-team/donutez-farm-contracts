const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  owner: dev.pkh,
  tokens: new MichelsonMap(),
  tokens_count: new MichelsonMap(),
  allowances_tmp: new MichelsonMap(),
  ledger_tmp: new MichelsonMap(),
  metadata_tmp: new MichelsonMap(),
  token_metadata_tmp: new MichelsonMap(),
};
