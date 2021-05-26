#include "../partial/IYFConstructor.ligo"
#include "../partial/YFConstructorMethods.ligo"

function main(const action : yf_constructor_action; const s : yf_constructor_storage) : yf_constructor_return is
  case action of
  | SetDeployFee(v)               -> set_deploy_fee(v, s)
  | SetDTZTokenAddress(v)         -> set_dtz_token_address(v, s)
  | SetDTZYFAddress(v)            -> set_dtz_yf_address(v, s)
  | DeployYF(v)                   -> deploy_yf(v.0, v.1, s)
  | WithdrawDTZTokens(v)          -> withdraw_dtz_tokens(s)
  | WithdrawDTZTokensCallback(v)  -> withdraw_dtz_tokens_callback(v, s)
  end
