function set_deploy_fee(
  const params          : deploy_fee_type;
  var s                 : storage_type)
                        : return_type is
  block {
    if Tezos.sender =/= s.admin
    then failwith("Allowed only for admin")
    else s.deploy_fee := params;
  } with (no_operations, s)

function set_dtz_token(
  const dtz_token       : set_dtz_token_type;
  var s                 : storage_type)
                        : return_type is
  block {
    if Tezos.sender =/= s.admin
    then failwith("Allowed only for admin")
    else s.dtz_token := dtz_token;
  } with (no_operations, s)

function set_dtz_farming(
  const dtz_farming     : set_dtz_farm_type;
  var s                 : storage_type)
                        : return_type is
  block {
    if Tezos.sender =/= s.admin
    then failwith("Allowed only for admin")
    else s.dtz_farming := dtz_farming;
  } with (no_operations, s)

function deploy_yf(
  const params          : deploy_farm_type;
  var s                 : storage_type)
                        : return_type is
  block {
    var operations := no_operations;

    if params.deploy_and_stake
    then {
      if deploy_stake_params.amount_for_stake < s.deploy_fee.min_stake_amount
      then failwith("Not enough tokens to stake")
      else skip;

      operations := Tezos.transaction(
        TransferType(Tezos.sender, (Tezos.self_address, s.deploy_fee.deploy_and_stake_fee)),
        0mutez,
        get_token_transfer_entrypoint(s.dtz_token)
      ) # operations;
      operations := Tezos.transaction(
        StakeForType(Tezos.sender, deploy_stake_params.amount_for_stake),
        0mutez,
        get_dtz_yf_stake_for_entrypoint(s)
      ) # operations;
    }
    else {
      operations := Tezos.transaction(
        TransferType(Tezos.sender, (Tezos.self_address, s.deploy_fee.deploy_fee)),
        0mutez,
        get_token_transfer_entrypoint(s.dtz_token)
      ) # operations;
    };

    const farming_storage : yf_storage = record[
      total_staked = 0n;
      share_reward = 0n;
      last_updated = Tezos.now;
      ledger = (big_map [] : big_map(address, yf_account));
      yf_params = deploy_params;
      yf_constructor = Tezos.self_address;
    ];
    const result : (operation * address) = deploy_contract((None : option(key_hash)), 0mutez, farming_storage);

    case (s.yield_farmings[Tezos.sender] : option(set(address))) of
      None    -> s.yield_farmings[Tezos.sender] := set [result.1]
    | Some(v) -> s.yield_farmings[Tezos.sender] := Set.add(result.1, v)
    end;

    operations := result.0 # operations;
  } with (operations, s)

function withdraw_dtz_tokens(
  const s               : storage_type)
                        : return_type is
  block {
    if Tezos.sender =/= s.admin
    then failwith("Allowed only for admin")
    else skip;

    var dtz_token : contract(get_balance_type) := nil;

    case (
      Tezos.get_entrypoint_opt("%getBalance", s.dtz_token)
                        : option(contract(get_balance_type))
    ) of
      None    -> failwith("DTZ token not found")
    | Some(contr) -> dtz_token := contr
    end;

    var params : get_balance_type := nil;

    case (
      Tezos.get_entrypoint_opt(
        "%withdrawDTZTokensCallback",
        Tezos.self_address
      ) : option(contract(nat))
    ) of
      None    -> failwith("Callback function not found")
    | Some(p) -> params := GetBalanceType(s.dtz_token, p)
    end;
  } with (list [
    Tezos.transaction(
      params,
      0mutez,
      dtz_token
    )
  ], s)

function withdraw_dtz_tokens_callback(
  const dtz_amount      : nat;
  const s               : storage_type)
                        : return_type is
  (list [
    Tezos.transaction(
      TransferType(Tezos.self_address, (s.admin, dtz_amount)),
      0mutez,
      get_fa12_token_transfer_entrypoint(s.dtz_token)
    )
  ], s)
