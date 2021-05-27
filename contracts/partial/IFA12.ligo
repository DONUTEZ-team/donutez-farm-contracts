type token_id is nat

type account is [@layout:comb] record [
  balance           : nat;
  allowances        : map(address, nat);
]

type token_metadata_info is [@layout:comb] record [
  token_id          : token_id;
  token_info        : map(string, bytes);
]

type fa12_storage is [@layout:comb] record [
  total_supply      : nat;
  ledger            : big_map(address, account);
  metadata          : big_map(string, bytes);
  token_metadata    : big_map(token_id, token_metadata_info);
]

type return is list(operation) * fa12_storage

type transfer_params is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type approve_params is michelson_pair(address, "spender", nat, "value")
type get_balance_params is michelson_pair(address, "owner", contract(nat), "")
type get_allowance_params is michelson_pair(michelson_pair(address, "owner", address, "spender"), "", contract(nat), "")
type get_total_supply_params is unit * contract(nat)

type fa12_token_action is
| Transfer of transfer_params
| Approve of approve_params
| GetBalance of get_balance_params
| GetAllowance of get_allowance_params
| GetTotalSupply of get_total_supply_params

[@inline] const no_operations : list(operation) = nil;
