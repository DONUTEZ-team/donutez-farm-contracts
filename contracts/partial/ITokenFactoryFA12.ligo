type token_id is nat

type account is [@layout:comb] record [
  balance               : nat;
  allowances            : map(address, nat);
]

type token_metadata_info is [@layout:comb] record [
  token_id              : nat;
  token_info            : map(string, bytes);
]

type factory_storage is [@layout:comb] record [
  owner                 : address;
  admin                 : address;
  tokens                : big_map(address, map(nat, address));
  tokens_count          : big_map(address, nat);
  allowances_tmp        : map(address, nat);
  ledger_tmp            : big_map(address, account);
  metadata_tmp          : big_map(string, bytes);
  token_metadata_tmp    : big_map(token_id, token_metadata_info);
]

type token_storage is [@layout:comb] record [
  total_supply          : nat;
  ledger                : big_map(address, account);
  metadata              : big_map(string, bytes);
  token_metadata        : big_map(token_id, token_metadata_info);
]

type launch_token_params is [@layout:comb] record [
  total_supply          : nat;
  metadata              : big_map(string, bytes);
  token_metadata        : big_map(nat, token_metadata_info);
]

type factory_return is list(operation) * factory_storage

type deploy_token_func is (option(key_hash) * tez * token_storage) -> (operation * address)

type factory_action is
| LaunchToken of launch_token_params
