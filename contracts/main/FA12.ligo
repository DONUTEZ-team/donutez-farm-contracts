#include "../partial/fa12/i_fa12.ligo"
#include "../partial/fa12/fa12_helpers.ligo"
#include "../partial/fa12/fa12_methods.ligo"

function main(
  const action          : action_type;
  const s               : storage_type)
                        : return_type is
  case action of
    Transfer(params)        -> transfer(params.0, params.1.0, params.1.1, s)
  | Approve(params)         -> approve(params.0, params.1, s)
  | GetBalance(params)      -> get_balance(params.0, params.1, s)
  | GetAllowance(params)    -> get_allowance(
                                params.0.0,
                                params.0.1,
                                params.1,
                                s
                              )
  | GetTotalSupply(params)  -> get_total_supply(params.1, s)
  end
