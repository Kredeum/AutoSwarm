import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';
import { utilsError } from '../swarm/utils';

import { jsonGet } from '../constants/json';
import { readPublicClient } from './read';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const readPostageBatches = async (chainId: number): Promise<[Address, number, bigint]> => {
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

const readPostageBatchesLegacy = async (chainId: number): Promise<[Address, number, bigint]> => {
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

const readPostageLastPrice = async (chainId: number): Promise<bigint> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const readPostageRemainingBalance = async (chainId: number): Promise<bigint> => {
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

export {
	readPostageBatches,
	readPostageBatchesLegacy,
	readPostageLastPrice,
	readPostageRemainingBalance
};
