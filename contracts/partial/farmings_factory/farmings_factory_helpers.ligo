function get_dtz_farming_stake_for_entrypoint(
  const s               : storage_type)
                        : contract(stake_for_type) is
  case (
    Tezos.get_entrypoint_opt("%stake_for", s.dtz_farming)
                        : option(contract(stake_for_type))
  ) of
    Some(contr) -> contr
  | None        -> (
    failwith("DTZ farming %stake_for entrypoint not found")
                        : contract(stake_for_type)
    )
  end

const deploy_contract : deploy_farming =
[%Michelson(
  {|
    {
      UNPPAIIR;
      CREATE_CONTRACT
#include "../compiled/farming.tz"
      ;
      PAIR;
    }
  |} : deploy_farming
)];
