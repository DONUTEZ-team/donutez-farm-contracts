#include "./ICommon.ligo"

type deploy_fee_params is [@layout:comb] record [
  deploy_fee            : nat;
  deploy_and_stake_fee  : nat;
  min_stake_amount      : nat;
]

type deploy_and_stake_params is [@layout:comb] record [
  deploy_and_stake      : bool;
  amount_for_stake      : nat;
]

type yf_constructor_storage is [@layout:comb] record [
  admin: address;
  dtz_token: address;
  dtz_yf: address;
  deploy_fee: deploy_fee_params;
  yield_farmings: map(address, set(address));
]

type yf_constructor_return is list(operation) * yf_constructor_storage

type deploy_yf_params_type is deploy_yf_params * deploy_and_stake_params

type deploy_yf_contract_function is (option(key_hash) * tez * yf_storage) -> (operation * address)

type get_balance_params is michelson_pair(address, "owner", contract(nat), "")
type get_balance_type is GetBalanceType of get_balance_params

type stake_for_type is StakeForType of address * nat

type yf_constructor_action is
| SetDeployFee of deploy_fee_params
| SetDTZTokenAddress of address
| SetDTZYFAddress of address
| DeployYF of deploy_yf_params_type
| WithdrawDTZTokens of unit
| WithdrawDTZTokensCallback of nat
