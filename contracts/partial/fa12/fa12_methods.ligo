function transfer(
  const from_           : address;
  const to_             : address;
  const value           : nat;
  var s                 : storage_type)
                        : return_type is
  block {
    var owner : account_type := get_account(from_, s);

    if owner.balance < value
    then failwith("NotEnoughBalance")
    else skip;

    if from_ =/= Tezos.sender
    then {
      const allowance : nat = get_allowance(owner, Tezos.sender);

      if allowance < value
      then failwith("NotEnoughAllowance")
      else skip;

      owner.allowances[Tezos.sender] := abs(allowance - value);
    }
    else skip;

    owner.balance := abs(owner.balance - value);

    s.ledger[from_] := owner;

    var recipient : account_type := get_account(to_, s);

    recipient.balance := recipient.balance + value;

    s.ledger[to_] := recipient;
  } with (no_operations, s)

function approve(
  const spender         : address;
  const value           : nat;
  var s                 : storage_type)
                        : return_type is
  block {
    var owner : account_type := get_account(Tezos.sender, s);
    const allowance : nat = get_allowance(owner, spender);

    if allowance > 0n and value > 0n
    then failwith("UnsafeAllowanceChange")
    else skip;

    owner.allowances[spender] := value;

    s.ledger[Tezos.sender] := owner;
  } with (no_operations, s)

function get_balance(
  const owner           : address;
  const contr           : contract(nat);
  const s               : storage_type)
                        : return_type is
  block {
    const owner : account_type = get_account(owner, s);
  } with (list [
    Tezos.transaction(
      owner.balance,
      0tz,
      contr
    )
  ], s)

function get_allowance(
  const owner           : address;
  const spender         : address;
  const contr           : contract(nat);
  const s               : storage_type)
                        : return_type is
  (list [
    Tezos.transaction(
      get_allowance(get_account(owner, s), spender),
      0tz,
      contr
    )
  ], s)

function get_total_supply(
  const contr           : contract(nat);
  const s               : storage_type)
                        : return_type is
  (list [
    Tezos.transaction(
      s.total_supply,
      0tz,
      contr
    )
  ], s)
