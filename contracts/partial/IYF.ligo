#include "./ICommon.ligo"

type yf_return is list(operation) * yf_storage

type yf_action is
| Stake of nat
| StakeFor of address * nat
| Unstake of nat
| Claim of unit
