function stake(
  const value           : stake_type;
  const s               : storage_type)
                        : return_type is
  stake_(Tezos.sender, Tezos.self_address, value, s)

function stake_for(
  const params          : stake_for_type;
  const s               : storage_type)
                        : return_type is
  block {
    if Tezos.sender =/= s.factory then
      failwith("Farming/not-factory")
    else
      skip;
  } with stake_(params.user, Tezos.self_address, params.amount, s)

function unstake(
  const params          : unstake_type;
  var s                 : storage_type)
                        : return_type is
  block {
    s := update_rewards(s);

    var user : account_type := get_account(Tezos.sender, s);
    var value : nat := params.amount;

    user.earned := user.earned + abs(user.staked * s.rps - user.prev_earned);

    if params.amount = 0n
    then value := user.staked
    else skip;

    if value <= user.staked
    then skip
    else failwith("Farming/low-staked-balance");

    user.staked := abs(user.staked - value);
    user.prev_earned := user.staked * s.rps;

    s.ledger[Tezos.sender] := user;
    s.staked := abs(s.staked - value);
  } with (list [
    Tezos.transaction(
      TransferType(Tezos.self_address, (params.receiver, value)),
      0mutez,
      get_fa12_token_transfer_entrypoint(s.staked_token)
    )
  ], s)

function claim(
  const receiver        : claim_type;
  var s                 : storage_type)
                        : return_type is
  block {
    s := update_rewards(s);

    var operations := no_operations;
    var user : account_type := get_account(Tezos.sender, s);
    const earned : nat = user.earned / precision;

    user.earned := user.earned + abs(user.staked * s.rps - user.prev_earned);
    user.prev_earned := user.staked * s.rps;

    if earned = 0n
    then skip
    else {
      user.earned := abs(user.earned - earned * precision);

      operations := Tezos.transaction(
        TransferType(Tezos.self_address, (receiver, earned)),
        0mutez,
        get_fa12_token_transfer_entrypoint(s.reward_token)
      ) # operations;

      user.earned := 0n;
    };

    s.ledger[Tezos.sender] := user;
  } with (operations, s)
