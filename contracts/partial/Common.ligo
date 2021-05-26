function get_token_transfer_entrypoint(const token : address) : contract(transfer_type) is
  case (Tezos.get_entrypoint_opt("%transfer", token) : option(contract(transfer_type))) of
  | Some(c) -> c
  | None -> (failwith("Common/token-transfer-entrypoint-not-found") : contract(transfer_type))
  end
