type mining_params is [@layout:comb] record [
  reward_token          : address;
  lifetime              : nat;
  period_in_seconds     : nat;
  reward_per_period     : nat;
]

type deploy_yf_params is [@layout:comb] record [
  lp_token              : address;
  mining_params         : mining_params;
]

type yf_account is [@layout:comb] record [
  staked                : nat;
  reward                : nat;
  former                : nat;
]

type yf_storage is [@layout:comb] record [
  total_staked          : nat;
  share_reward          : nat;
  last_updated          : timestamp;
  ledger                : big_map(address, yf_account);
  yf_params             : deploy_yf_params;
  yf_constructor        : address;
]

type transfer_params is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type transfer_type is TransferType of transfer_params

[@inline] const no_operations : list(operation) = nil;
