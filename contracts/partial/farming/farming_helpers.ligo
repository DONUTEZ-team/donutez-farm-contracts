function get_fa12_token_transfer_entrypoint(
  const token           : address)
                        : contract(fa12_transfer_type) is
  case (
    Tezos.get_entrypoint_opt("%transfer", token)
                        : option(contract(fa12_transfer_type))
  ) of
    Some(contr) -> contr
  | None -> (
    failwith("Farming/FA1.2-token-transfer-entrypoint-404")
                        : contract(fa12_transfer_type)
    )
  end

function get_account(
  const addr            : address;
  const s               : storage_type)
                        : account_type is
  case s.ledger[addr] of
    Some(v) -> v
  | None    -> record [
    staked      = 0n;
    earned      = 0n;
    prev_earned = 0n;
  ]
  end

function update_rewards(
  var s                 : storage_type)
                        : storage_type is
  block {
    if s.upd < Tezos.level
    then {
      if s.staked > 0n
      then {
        const delta : nat = abs(Tezos.level - s.upd);
        const reward : nat = delta * s.reward_per_period * precision;

        s.rps := s.rps + reward / s.staked;
      }
      else skip;

      s.upd := Tezos.level;
    }
    else skip;
  } with s

function stake_(
  const addr            : address;
  const this            : address;
  const value           : nat;
  var s                 : storage_type)
                        : return_type is
  block {
    s := update_rewards(s);

    var user : account_type := get_account(addr, s);

    user.earned := user.earned + abs(user.staked * s.rps - user.prev_earned);
    user.staked := user.staked + value;
    user.prev_earned := user.staked * s.rps;

    s.ledger[addr] := user;
    s.staked := s.staked + value;
  } with (list [
    Tezos.transaction(
      TransferType(addr, (this, value)),
      0mutez,
      get_fa12_token_transfer_entrypoint(s.staked_token)
    )
  ], s)
