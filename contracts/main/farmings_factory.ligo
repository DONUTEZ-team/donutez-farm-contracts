#include "../partial/farmings_factory/i_farmings_factory.ligo"
#include "../partial/farmings_factory/farmings_factory_helpers.ligo"
#include "../partial/farmings_factory/farmings_factory_methods.ligo"

function main(
  const action          : action_type;
  const s               : storage_type)
                        : return_type is
  case action of
    SetDeployFee(params)               -> set_deploy_fee(params, s)
  | SetDTZToken(params)                -> set_dtz_token(params, s)
  | SetDTZFarming(params)              -> set_dtz_farming(params, s)
  | DeployFarming(params)              -> deploy_farming(params, s)
  | WithdrawDTZTokens(params)          -> withdraw_dtz_tokens(params)
  | WithdrawDTZTokensCallback(params)  -> withdraw_dtz_tokens_callback(
                                            params,
                                            s
                                          )
  end
