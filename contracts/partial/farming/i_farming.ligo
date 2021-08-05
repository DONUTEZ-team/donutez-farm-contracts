type account_type       is [@layout:comb] record [
  staked                  : nat;
  earned                  : nat;
  prev_earned             : nat;
]

type storage_type       is [@layout:comb] record [
  ledger                  : big_map(address, account_type);
  staked_token            : address;
  reward_token            : address;
  factory                 : address;
  reward_per_period       : nat;
  period_in_blocks        : nat;
  lifetime                : nat;
  staked                  : nat;
  upd                     : nat;
  rps                     : nat;
]

type stake_type         is nat

type stake_for_type     is [@layout:comb] record [
  user                    : address;
  amount                  : nat;
]

type unstake_type       is [@layout:comb] record [
  receiver                : address;
  amount                  : nat;
]

type claim_type         is address

type action_type        is
  Stake                   of stake_type
| Stake_for               of stake_for_type
| Unstake                 of unstake_type
| Claim                   of claim_type

type return_type        is (list(operation) * storage_type)

type transfer_type      is michelson_pair(
  address, "from",
  michelson_pair(address, "to", nat, "value"), ""
)

type fa12_transfer_type is TransferType of transfer_type

[@inline] const no_operations : list(operation) = nil;

[@inline] const precision : nat = 1000000000000000000n;
