#include "./Common.ligo"

function get_account(const user : address; const s : yf_storage) : yf_account is
  block {
    const acc : yf_account = case s.ledger[user] of
      | Some(a) -> a
      | None -> record[
        staked = 0n;
        reward = 0n;
        former = 0n;
      ]
    end;
  } with acc

function update_rewards(var s : yf_storage) : yf_storage is
  block {
    if s.last_updated < Tezos.now then block {
      if s.total_staked > 0n then block {
        const delta_time_in_seconds : nat = abs(Tezos.now - s.last_updated);
        const new_rewards : nat = delta_time_in_seconds * s.yf_params.mining_params.reward_per_period;

        s.share_reward := s.share_reward + new_rewards / s.total_staked;
      }
      else
        skip;

      s.last_updated := Tezos.now;
    }
    else
      skip;
  } with s

function stake_(const addr : address; const this : address; const value : nat; const s : yf_storage) : yf_return is
  block {
    s := update_rewards(s);

    var acc : yf_account := get_account(addr, s);

    acc.reward := acc.reward + abs(acc.staked * s.share_reward - acc.former);
    acc.staked := acc.staked + value;
    acc.former := acc.staked * s.share_reward;

    s.ledger[addr] := acc;
    s.total_staked := s.total_staked + value;
  } with (list [
    Tezos.transaction(
      TransferType(addr, (this, value)),
      0mutez,
      get_token_transfer_entrypoint(s.yf_params.lp_token)
    )
  ], s)

function stake(const value : nat; var s : yf_storage) : yf_return is
  stake_(Tezos.sender, Tezos.self_address, value, s)

function stake_for(const addr : address; const value : nat; const s : yf_storage) : yf_return is
  block {
    if Tezos.sender =/= s.yf_constructor then
      failwith("YF/not-yf-constructor")
    else
      skip;
  } with stake_(addr, Tezos.self_address, value, s)

function unstake(var value : nat; var s : yf_storage) : yf_return is
  block {
    s := update_rewards(s);

    var acc : yf_account := get_account(Tezos.sender, s);

    acc.reward := acc.reward + abs(acc.staked * s.share_reward - acc.former);

    if value = 0n then
      value := acc.staked
    else
      skip;

    if value <= acc.staked then
      skip
    else
      failwith("YF/staked-balance-too-low");

    acc.staked := abs(acc.staked - value);
    acc.former := acc.staked * s.share_reward;

    s.ledger[Tezos.sender] := acc;
    s.total_staked := abs(s.total_staked - value);
  } with (list [
    Tezos.transaction(
      TransferType(Tezos.self_address, (Tezos.sender, value)),
      0mutez,
      get_token_transfer_entrypoint(s.yf_params.lp_token)
    )
  ], s)

function claim(var s : yf_storage) : yf_return is
  block {
    s := update_rewards(s);

    var operations := no_operations;
    var acc : yf_account := get_account(Tezos.sender, s);

    acc.reward := acc.reward + abs(acc.staked * s.share_reward - acc.former);
    acc.former := acc.staked * s.share_reward;

    if acc.reward = 0n then
      skip
    else block {
      operations := Tezos.transaction(
        TransferType(Tezos.self_address, (Tezos.sender, acc.reward)),
        0mutez,
        get_token_transfer_entrypoint(s.yf_params.mining_params.reward_token)
      ) # operations;

      acc.reward := 0n;
    };

    s.ledger[Tezos.sender] := acc;
  } with (operations, s)
