import type { gnosis, localhost, sepolia } from 'viem/chains';
import type { anvil } from '$lib/ts/constants/anvil';

type ChainInJson = typeof gnosis | typeof sepolia | typeof anvil | typeof localhost;

export { type ChainInJson };
