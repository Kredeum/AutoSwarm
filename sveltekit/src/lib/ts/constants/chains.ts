import type { Chain } from 'viem';
import {
	arbitrum,
	base,
	bsc,
	gnosis,
	linea,
	mainnet,
	optimism,
	polygon,
	scroll,
	zkSync,
	sepolia
} from 'viem/chains';
import { anvil } from './anvil';

type ChainMapType = Map<number, Chain>;

const bzzChains = [gnosis, sepolia, anvil];
const bzzChainsId = bzzChains.map((chain) => chain.id);
type BzzChainIdType = (typeof bzzChainsId)[number];

const nftChains = [arbitrum, base, bsc, gnosis, linea, mainnet, optimism, polygon, scroll, zkSync];
const nftChainsId = nftChains.map((chain) => chain.id);
type NftChainIdType = (typeof nftChainsId)[number];

const allChains = [...new Set([...bzzChains, ...nftChains])];

const chainsMap: ChainMapType = new Map();
for (const chain of allChains) chainsMap.set(chain.id, chain);

const chainGet = (id: number): Chain => chainsMap.get(id) || mainnet;
const chainGetExplorer = (id: number): string => {
	const chain = chainGet(id);

	return chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url || '';
};

export { bzzChains, bzzChainsId, nftChains, nftChainsId, chainsMap, chainGet , chainGetExplorer};
export type { ChainMapType, BzzChainIdType, NftChainIdType };
