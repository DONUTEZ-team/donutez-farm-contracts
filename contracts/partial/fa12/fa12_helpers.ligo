function get_account(
  const user            : address;
  const s               : storage_type)
                        : account_type is
  block {
    var acc : account_type := record [
      allowances = (map [] : map(address, nat));
      balance    = 0n;
    ];

    case s.ledger[user] of
      None    -> skip
    | Some(a) -> acc := a
    end;
  } with acc

function get_allowance(
  const owner           : account_type;
  const spender         : address)
                        : nat is
  case owner.allowances[spender] of
    None    -> 0n
  | Some(v) -> v
  end
