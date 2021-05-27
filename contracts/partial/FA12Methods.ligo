function get_account(const addr : address; const s : fa12_storage) : account is
  block {
    var acc : account := record [
      balance = 0n;
      allowances = (map [] : map(address, nat));
    ];

    case s.ledger[addr] of
    | None -> skip
    | Some(a) -> acc := a
    end;
  } with acc

function get_allowance(const owner : account; const spender : address; const s : fa12_storage) : nat is
  case owner.allowances[spender] of
  | Some(v) -> v
  | None -> 0n
  end

function transfer(const from_ : address; const to_ : address; const value : nat; var s : fa12_storage) : return is
  block {
    var sender_account : account := get_account(from_, s);

    if sender_account.balance < value then
      failwith("NotEnoughBalance")
    else
      skip;

    if from_ =/= Tezos.sender then block {
      const spender_allowance : nat = get_allowance(sender_account, Tezos.sender, s);

      if spender_allowance < value then
        failwith("NotEnoughAllowance")
      else
        skip;

      sender_account.allowances[Tezos.sender] := abs(spender_allowance - value);
    } else
      skip;

    sender_account.balance := abs(sender_account.balance - value);
    s.ledger[from_] := sender_account;

    var recipient_account : account := get_account(to_, s);

    recipient_account.balance := recipient_account.balance + value;
    s.ledger[to_] := recipient_account;
  } with (no_operations, s)

function approve(const spender : address; const value : nat; var s : fa12_storage) : return is
  block {
    var sender_account : account := get_account(Tezos.sender, s);
    const spender_allowance : nat = get_allowance(sender_account, spender, s);

    if spender_allowance > 0n and value > 0n then
      failwith("UnsafeAllowanceChange")
    else
      skip;

    sender_account.allowances[spender] := value;
    s.ledger[Tezos.sender] := sender_account;
  } with (no_operations, s)

function get_balance(const owner : address; const contr : contract(nat); const s : fa12_storage) : return is
  block {
    const owner_account : account = get_account(owner, s);
  } with (list [Tezos.transaction(owner_account.balance, 0tz, contr)], s)

function get_allowance(const owner : address; const spender : address; const contr : contract(nat); const s : fa12_storage) : return is
  block {
    const owner_account : account = get_account(owner, s);
    const spender_allowance : nat = get_allowance(owner_account, spender, s);
  } with (list [Tezos.transaction(spender_allowance, 0tz, contr)], s)

function get_total_supply(const contr : contract(nat); const s : fa12_storage) : return is
  (list [Tezos.transaction(s.total_supply, 0tz, contr)], s)
