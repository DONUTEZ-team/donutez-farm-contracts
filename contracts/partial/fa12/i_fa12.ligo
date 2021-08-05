type token_id_type      is nat

type account_type       is [@layout:comb] record [
  allowances              : map(address, nat);
  balance                 : nat;
]

type tok_metadata_type  is [@layout:comb] record [
  token_info              : map(string, bytes);
  token_id                : token_id_type;
]

type storage_type       is [@layout:comb] record [
  token_metadata          : big_map(token_id_type, tok_metadata_type);
  ledger                  : big_map(address, account_type);
  metadata                : big_map(string, bytes);
  total_supply            : nat;
]

type return_type        is (list(operation) * storage_type)

type transfer_type      is michelson_pair(
  address, "from",
  michelson_pair(address, "to", nat, "value"), ""
)

type approve_type       is michelson_pair(
  address, "spender",
  nat, "value"
)

type balance_of_type    is michelson_pair(
  address, "owner",
  contract(nat), ""
)

type allowance_type     is michelson_pair(
  michelson_pair(address, "owner", address, "spender"), "",
  contract(nat), ""
)

type total_supply_type  is (unit * contract(nat))

type action_type        is
  Transfer                of transfer_type
| Approve                 of approve_type
| GetBalance              of balance_of_type
| GetAllowance            of allowance_type
| GetTotalSupply          of total_supply_type

[@inline] const no_operations : list(operation) = nil;
