const { MichelsonMap } = require("@taquito/michelson-encoder");

const { dev } = require("../scripts/sandbox/accounts");

module.exports = {
  admin: dev.pkh,
  dtzToken: "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg",
  dtzYF: "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg",
  deployFee: {
    deployFee: "10",
    deployAndStakeFee: "5",
    minStakeAmount: "5",
  },
  yieldFarmings: new MichelsonMap(),
};
