type deploy_fee_type    is [@layout:comb] record [
  deploy_fee            : nat;
  deploy_and_stake_fee  : nat;
  min_stake_amount      : nat;
]

type set_dtz_token_type is address

type set_dtz_farm_type  is address

type deploy_type        is [@layout:comb] record [

]

type deploy_stake_type  is [@layout:comb] record [
  deploy_and_stake      : bool;
  amount_for_stake      : nat;
]

type storage_type       is [@layout:comb] record [
  farmings              : map(address, set(address));
  deploy_fee            : deploy_fee_type;
  dtz_farming           : address;
  dtz_token             : address;
  admin                 : address;
]

type return_type        is (list(operation) * storage_type)

type deploy_farm_type   is (deploy_type * deploy_stake_type)

type withdraw1_type     is unit

type withdraw2_type     is nat

type deploy_farming     is
  (option(key_hash) * tez * yf_storage) -> (operation * address)

// type get_balance_params is michelson_pair(address, "owner", contract(nat), "")
// type get_balance_type is GetBalanceType of get_balance_params

type stake_for_type     is StakeForType of (address * nat)

type action_type        is
  SetDeployFee            of deploy_fee_type
| SetDTZToken             of set_dtz_token_type
| SetDTZFarming           of set_dtz_farm_type
| DeployFarming           of deploy_farm_type
| WithdrawDTZTokens1      of withdraw1_type
| WithdrawDTZTokens2      of withdraw2_type
