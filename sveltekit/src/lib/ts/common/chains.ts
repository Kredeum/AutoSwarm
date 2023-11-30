import { http, type Chain, type HttpTransport } from 'viem';
import { arbitrum, bsc, gnosis, mainnet, optimism, polygon, sepolia } from 'viem/chains';
import { anvil } from '../constants/anvil';

type ChainMapType = Map<number, Chain>;

const bzzChains = [gnosis, sepolia, anvil];
const bzzChainsId = bzzChains.map((chain) => chain.id);
type BzzChainIdType = (typeof bzzChainsId)[number];

const nftChains = [mainnet, gnosis, polygon, bsc, arbitrum, optimism];
const nftChainsId = nftChains.map((chain) => chain.id);
type NftChainIdType = (typeof nftChainsId)[number];

const allChains = [...new Set([...bzzChains, ...nftChains])];

const chainsMap: ChainMapType = new Map();
for (const chain of allChains) chainsMap.set(chain.id, chain);

const chainGet = (chainId: number): Chain | undefined => {
	if (!chainId) return;

	const chain = chainsMap.get(chainId);
	if (!chain) return;

	return chain;
};

const chainGetExplorer = (id: number): URL | undefined => {
	const chain = chainGet(id);
	const url = chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url;

	return url ? new URL(url) : undefined;
};

const chainGetWithTransport = (
	chainId: number
): { chain: Chain; transport: HttpTransport } | undefined => {
	const chain = chainGet(chainId);
	if (!chain) return;

	const INFURA_API_KEY = '7e5ff61abb704742b7783199fbf36327';

	let rpcUrl: string | undefined;

	if (chainId === anvil.id) {
		rpcUrl = 'http://127.0.0.1:8545';
	} else if (chainId === gnosis.id) {
		// rpcUrl = 'https://rpc.ankr.com/gnosis';
		rpcUrl = 'https://gnosis.publicnode.com';
	} else if (chainId === sepolia.id) {
		rpcUrl = `https://sepolia.infura.io/v3/${INFURA_API_KEY}`;
	} else if (chainId === mainnet.id) {
		rpcUrl = `https://mainnet.infura.io/v3/${INFURA_API_KEY}`;
	} else if (chainId === polygon.id) {
		rpcUrl = `https://polygon-mainnet.infura.io/v3/${INFURA_API_KEY}`;
	} else if (chainId === arbitrum.id) {
		rpcUrl = `https://arbitrum-mainnet.infura.io/v3/${INFURA_API_KEY}`;
	} else if (chainId === optimism.id) {
		rpcUrl = `https://optimism-mainnet.infura.io/v3/${INFURA_API_KEY}`;
	} else if (chainId === bsc.id) {
		// rpcUrl = 'https://rpc.ankr.com/bsc';
		rpcUrl = 'https://bsc.publicnode.com';
	} else {
		throw new Error(`chainGetWithTransport: No rpc url found for chainId 1${chainId}`);
	}

	// console.info('chainGetWithTransport ~ rpcUrl:', chainId, rpcUrl);
	const transport = http(rpcUrl);

	return { chain, transport };
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
