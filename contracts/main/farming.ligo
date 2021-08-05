#include "../partial/farming/i_farming.ligo"
#include "../partial/farming/farming_helpers.ligo"
#include "../partial/farming/farming_methods.ligo"

function main(
  const action          : action_type;
  const storage         : storage_type)
                        : return_type is
  case action of
    Stake(params)      -> stake(params, storage)
  | Stake_for(params)  -> stake_for(params, storage)
  | Unstake(params)    -> unstake(params, storage)
  | Claim(params)      -> claim(params, storage)
  end
