import type { Chain } from 'viem';
import { mainnet, gnosis, sepolia } from 'viem/chains';
import { anvil } from './anvil';

type ChainMapType = Map<number, Chain>;

const chains = [gnosis, sepolia, anvil];

const chainsId = chains.map((chain) => chain.id);
type ChainIdType = (typeof chainsId)[number];

const chainsMap: ChainMapType = new Map();
for (const chain of chains) chainsMap.set(chain.id, chain);

const chainGet = (id: number): Chain => chainsMap.get(id) || mainnet;

export { chains, chainsMap, chainsId, chainGet };
export type { ChainMapType, ChainIdType };
