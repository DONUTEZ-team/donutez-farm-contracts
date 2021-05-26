declare var tezos: any;

const { confirmOperation } = require("./confirmation");

export async function bakeBlocks(count: number) {
  for (let i = 0; i < count; i++) {
    let operation = await tezos.contract.transfer({
      to: await tezos.signer.publicKeyHash(),
      amount: 1,
    });

    await confirmOperation(tezos, operation.hash);
  }
}
