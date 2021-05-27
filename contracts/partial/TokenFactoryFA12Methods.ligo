const deploy_token : deploy_token_func =
[%Michelson(
  {|
    {
      UNPPAIIR;
      CREATE_CONTRACT
#include "../compiled/FA12.tz"
      ;
      PAIR;
    }
  |} : deploy_token_func
)];

function launch_token(const params : launch_token_params; var s : factory_storage) : factory_return is
  block {
    const user : account = record [
      balance = params.total_supply;
      allowances = s.allowances_tmp;
    ];

    s.ledger_tmp := (big_map [(Tezos.sender : address) -> (user : account)] : big_map(address, account));
    s.metadata_tmp := params.metadata;
    s.token_metadata_tmp := params.token_metadata;

    const tok_storage : token_storage = record [
      total_supply = params.total_supply;
      ledger = s.ledger_tmp;
      metadata = s.metadata_tmp;
      token_metadata = s.token_metadata_tmp;
    ];

    const res : (operation * address) = deploy_token((None : option(key_hash)), 0mutez, tok_storage);

    const user_tokens_count : nat = case (s.tokens_count[Tezos.sender] : option(nat)) of
    | None -> 0n
    | Some(value) -> value
    end;

    case (s.tokens[Tezos.sender] : option(map(nat, address))) of
    | None -> s.tokens[Tezos.sender] := map [0n -> res.1]
    | Some(value) -> block {
      value[user_tokens_count + 1n] := res.1;
      s.tokens[Tezos.sender] := value;
    }
    end;

    case (s.tokens_count[Tezos.sender] : option(nat)) of
    | None -> s.tokens_count[Tezos.sender] := 0n
    | Some(value) -> s.tokens_count[Tezos.sender] := value + 1n
    end;
  } with (list [res.0], s)
