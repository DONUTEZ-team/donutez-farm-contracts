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
      allowances = s.tmp1;
    ];

    function fill_metadata(var acc : big_map(string, bytes); const params : (string * bytes)) : big_map(string, bytes) is
      block {
        acc[params.0] := params.1;
      } with acc;

    function clear_metadata(var acc : big_map(string, bytes); const params : (string * bytes)) : big_map(string, bytes) is
      block {
        remove params.0 from map acc;
      } with acc;

    function fill_token_metadata_by_id(var acc : map(string, bytes); const params : (string * bytes)) : map(string, bytes) is
      block {
        acc[params.0] := params.1;
      } with acc;

    function clear_token_metadata_by_id(var acc : map(string, bytes); const params : (string * bytes)) : map(string, bytes) is
      block {
        remove params.0 from map acc;
      } with acc;

    function fill_token_metadata(var acc : big_map(token_id, token_metadata_info); const params : (nat * list(string * bytes))) : big_map(token_id, token_metadata_info) is
      block {
        s.tmp2 := List.fold(fill_token_metadata_by_id, params.1, s.tmp2);

        acc[params.0] := record [
          token_id = params.0;
          token_info = s.tmp2;
        ];

        s.tmp2 := List.fold(clear_token_metadata_by_id, params.1, s.tmp2);
      } with acc;

    function clear_token_metadata(var acc : big_map(token_id, token_metadata_info); const params : (nat * list(string * bytes))) : big_map(token_id, token_metadata_info) is
      block {
        remove params.0 from map acc;
      } with acc;

    s.tmp3[Tezos.sender] := user;
    s.tmp4 := List.fold(fill_metadata, params.metadata, s.tmp4);
    s.tmp5 := List.fold(fill_token_metadata, params.token_metadata, s.tmp5);

    const tok_storage : token_storage = record [
      total_supply = params.total_supply;
      ledger = s.tmp3;
      metadata = s.tmp4;
      token_metadata = s.tmp5;
    ];

    const res : (operation * address) = deploy_token((None : option(key_hash)), 0mutez, tok_storage);

    remove Tezos.sender from map s.tmp3;
    s.tmp4 := List.fold(clear_metadata, params.metadata, s.tmp4);
    s.tmp5 := List.fold(clear_token_metadata, params.token_metadata, s.tmp5);

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
  } with (list [res.0], s)
