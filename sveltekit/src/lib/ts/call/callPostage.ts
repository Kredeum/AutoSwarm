import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';
import { utilsError } from '../swarm/utils';

import { jsonGet } from '../constants/json';
import { callPublicClient } from './call';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (chainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`callPostageBatches: No batchId in json ${chainId})`);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const callPostageBatchesLegacy = async (chainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`callPostageBatchesLegacy: No batchId in json ${chainId})`);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const callPostageLastPrice = async (chainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(chainId);

	const json = await jsonGet(chainId);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const callPostageRemainingBalance = async (chainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json))
		utilsError(`callPostageRemainingBalance: No batchId in json ${chainId})`);

	const data = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'remainingBalance',
		args: [json.batchId as Hex]
	});

	return data;
};

export {
	callPostageBatches,
	callPostageBatchesLegacy,
	callPostageLastPrice,
	callPostageRemainingBalance
};
