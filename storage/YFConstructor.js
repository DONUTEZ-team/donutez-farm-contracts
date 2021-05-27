const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  dtz_token: "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg",
  dtz_yf: "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg",
  deploy_fee: {
    deploy_fee: "10",
    deploy_and_stake_fee: "5",
    min_stake_amount: "5",
  },
  yield_farmings: new MichelsonMap(),
};
