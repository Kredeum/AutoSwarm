import { http, type Chain, type HttpTransport } from 'viem';
import { arbitrum, base, bsc, gnosis, mainnet, optimism, polygon, sepolia } from 'viem/chains';
import { anvil } from './anvil';
import { SEPOLIA_RPC } from './constants';

type ChainMapType = Map<number, Chain>;

const bzzChains = [gnosis, sepolia, anvil];
const bzzChainsId = bzzChains.map((chain) => chain.id);
type BzzChainIdType = (typeof bzzChainsId)[number];

const nftChains = [arbitrum, base, bsc, gnosis, mainnet, optimism, polygon];
const nftChainsId = nftChains.map((chain) => chain.id);
type NftChainIdType = (typeof nftChainsId)[number];

const allChains = [...new Set([...bzzChains, ...nftChains])];

const chainsMap: ChainMapType = new Map();
for (const chain of allChains) chainsMap.set(chain.id, chain);

const chainGet = (chainId: number): Chain => chainsMap.get(chainId) || mainnet;

const chainGetWithTransport = (chainId: number): { chain: Chain; transport: HttpTransport } => {
	const chain = chainGet(chainId);

	const transport = chainId == 11155111 ? http(SEPOLIA_RPC) : http();

	return { chain, transport };
};

const chainGetExplorer = (id: number): URL | undefined => {
	const chain = chainGet(id);
	const url = chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url;

	return url ? new URL(url) : undefined;
};

export {
	bzzChains,
	bzzChainsId,
	nftChains,
	nftChainsId,
	chainsMap,
	chainGet,
	chainGetWithTransport,
	chainGetExplorer
};
export type { ChainMapType, BzzChainIdType, NftChainIdType };
