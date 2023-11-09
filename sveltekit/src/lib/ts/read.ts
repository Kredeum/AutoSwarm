import {
	http,
	type Chain,
	type Address,
	type Block,
	type Hex,
	type PublicClient,
	createPublicClient
} from 'viem';
import {
	bzzTokenAbi,
	postageStampAbi,
	postageStampAbiBatcheslegacy,
	erc6551RegistryAbi
} from './abis';
import { SEPOLIA_RPC } from '$lib/ts/constants';
import { utilsError } from './utils';
import { chainGet } from './chains';
import { jsonGet } from './json';

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

const readLastPrice = async (chainId: number): Promise<bigint> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const readBzzBalance = async (chainId: number, address: Address): Promise<bigint | undefined> => {
	if (address === undefined) return;
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);

	return await publicClient.readContract({
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'balanceOf',
		args: [address]
	});
};

const readBatchLegacy = async (chainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`No batchId in json ${chainId})`);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readBatchNew = async (chainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`No batchId in json ${chainId})`);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readRemainingBalance = async (chainId: number): Promise<bigint> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`No batchId in json ${chainId})`);

	const data = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'remainingBalance',
		args: [json.batchId as Hex]
	});

	return data;
};

const readChainId = async (chain: Chain) => {
	const publicClient = await readPublicClient(chain.id);

	return await publicClient.getChainId();
};

export {
	readPublicClient,
	readChainId,
	readEnsName,
	readBatchNew,
	readLastPrice,
	readIsContract,
	readBzzBalance,
	readBatchLegacy,
	readRemainingBalance,
	readBlock
};
