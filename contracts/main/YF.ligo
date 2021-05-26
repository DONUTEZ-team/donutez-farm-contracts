#include "../partial/IYF.ligo"
#include "../partial/YFMethods.ligo"

function main(const action : yf_action; const s : yf_storage) : yf_return is
  case action of
  | Stake(v)      -> stake(v, s)
  | StakeFor(v)   -> stake_for(v.0, v.1, s)
  | Unstake(v)    -> unstake(v, s)
  | Claim(v)      -> claim(s)
  end
