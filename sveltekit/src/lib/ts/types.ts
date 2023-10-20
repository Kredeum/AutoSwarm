import type { gnosis, localhost, sepolia } from 'viem/chains';
import type { anvil } from '$lib/ts/anvil';

type ChainInJson = typeof gnosis | typeof sepolia | typeof anvil | typeof localhost;

export { type ChainInJson };
