#include "../partial/ITokenFactoryFA12.ligo"
#include "../partial/TokenFactoryFA12Methods.ligo"

function main(const action : factory_action; const s : factory_storage) : factory_return is
  case action of
  | LaunchToken(params) -> launch_token(params, s)
  end
