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
      allowances = (Map.empty : map(address, nat));
    ];

    s.metadata_tmp := params.metadata;
    s.token_info_tmp := params.token_info;
    s.token_metadata_tmp[0n] := record [
      token_id = 0n;
      token_info = s.token_info_tmp;
    ];

    const tok_storage : token_storage = record [
      total_supply = params.total_supply;
      ledger = (big_map [(Tezos.sender : address) -> (user : account)] : big_map(address, account));
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
      value[user_tokens_count] := res.1;
      s.tokens[Tezos.sender] := value;
    }
    end;

    case (s.tokens_count[Tezos.sender] : option(nat)) of
    | None -> s.tokens_count[Tezos.sender] := 1n
    | Some(value) -> s.tokens_count[Tezos.sender] := value + 1n
    end;

    s.token_info_tmp := (Map.empty : map(string, bytes));
    s.metadata_tmp := (Big_map.empty : big_map(string, bytes));
    s.token_metadata_tmp := (Big_map.empty : big_map(token_id, token_metadata_info));
  } with (list [res.0], s)
