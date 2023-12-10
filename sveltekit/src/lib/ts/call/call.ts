import { type Chain, type Address, type Block, type PublicClient, createPublicClient } from 'viem';
import { chainGetWithTransport } from '../common/chains';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

// publicClients Map used as cache
const _publicClients: Map<number, PublicClient> = new Map();

const _publicClient = (chainId: number): PublicClient => {
	const chainWithTransport = chainGetWithTransport(chainId);
	if (!chainWithTransport) throw Error(`No chain with transport for ${chainId}`);

	const publicClient = createPublicClient(chainWithTransport);
	_publicClients.set(chainId, publicClient);

	return publicClient;
};

const callPublicClient = (chainId: number): PublicClient =>
	_publicClients.get(chainId) || _publicClient(chainId);

const callBlockNumber = async (chainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(chainId);

	return await publicClient.getBlockNumber();
};

const callBlock = async (chainId: number, blockNumber?: bigint): Promise<Block> => {
	const publicClient = await callPublicClient(chainId);

	const param = blockNumber ? { blockNumber } : {};

	return await publicClient.getBlock(param);
};

const callEnsName = async (account: Address) =>
	await callPublicClient(1).getEnsName({ address: account });

const callIsContract = async (chainId: number, address: Address | undefined): Promise<boolean> => {
	if (!(address && address !== '0x0' && chainId > 0)) return false;

	const publicClient = await callPublicClient(chainId);

	const bytecode = await publicClient.getBytecode({ address });

	const isContract = (bytecode?.length || 0) > 0;

	// console.info('callIsContract', isContract, chainId, address);
	return isContract;
};

const callChainId = async (chain: Chain) => {
	const publicClient = await callPublicClient(chain.id);

	return await publicClient.getChainId();
};

export { callPublicClient, callChainId, callEnsName, callIsContract, callBlock, callBlockNumber };
