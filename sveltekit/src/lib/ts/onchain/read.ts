import {
	http,
	type Chain,
	type Address,
	type Block,
	type Hex,
	type PublicClient,
	createPublicClient
} from 'viem';
import { SEPOLIA_RPC } from '$lib/ts/constants/constants';
import { chainGet } from '../constants/chains';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

// publicClients Map used as cache
const _publicClients: Map<number, PublicClient> = new Map();

const _readPublicClient = (chainId: number): PublicClient => {
	const chain = chainGet(chainId);
	const transport = chainId == 11155111 ? http(SEPOLIA_RPC) : http();

	const publicClient = createPublicClient({ chain, transport });
	_publicClients.set(chainId, publicClient);

	return publicClient;
};

const readPublicClient = (chainId: number): PublicClient =>
	_publicClients.get(chainId) || _readPublicClient(chainId);

const readBlock = async (chainId: number, blockNumber?: bigint): Promise<Block> => {
	const publicClient = await readPublicClient(chainId);

	const param = blockNumber ? { blockNumber } : {};

	return await publicClient.getBlock(param);
};

const readEnsName = async (account: Address) =>
	await readPublicClient(1).getEnsName({ address: account });

const readIsContract = async (chainId: number, address: Address): Promise<boolean> => {
	if (address == '0x0') return false;
	const publicClient = await readPublicClient(chainId);

	const bytecode = await publicClient.getBytecode({ address });

	return Number(bytecode?.length || 0n) > 0;
};

const readChainId = async (chain: Chain) => {
	const publicClient = await readPublicClient(chain.id);

	return await publicClient.getChainId();
};

export { readPublicClient, readChainId, readEnsName, readIsContract, readBlock };
