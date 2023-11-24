import {
	http,
	type Chain,
	type Address,
	type Block,
	type PublicClient,
	createPublicClient
} from 'viem';
import { SEPOLIA_RPC } from '$lib/ts/constants/constants';
import { chainGetWithTransport } from '../constants/chains';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

// publicClients Map used as cache
const _publicClients: Map<number, PublicClient> = new Map();

const _publicClient = (chainId: number): PublicClient => {
	const publicClient = createPublicClient(chainGetWithTransport(chainId));
	_publicClients.set(chainId, publicClient);

	return publicClient;
};

const callPublicClient = (chainId: number): PublicClient =>
	_publicClients.get(chainId) || _publicClient(chainId);

const callBlock = async (chainId: number, blockNumber?: bigint): Promise<Block> => {
	const publicClient = await callPublicClient(chainId);

	const param = blockNumber ? { blockNumber } : {};

	return await publicClient.getBlock(param);
};

const callEnsName = async (account: Address) =>
	await callPublicClient(1).getEnsName({ address: account });

const callIsContract = async (chainId: number, address: Address): Promise<boolean> => {
	if (address == '0x0') return false;
	const publicClient = await callPublicClient(chainId);

	const bytecode = await publicClient.getBytecode({ address });

	return Number(bytecode?.length || 0n) > 0;
};

const callChainId = async (chain: Chain) => {
	const publicClient = await callPublicClient(chain.id);

	return await publicClient.getChainId();
};

export { callPublicClient, callChainId, callEnsName, callIsContract, callBlock };
