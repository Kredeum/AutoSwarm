import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';
import { utilsError } from '../common/utils';

import { jsonGet } from '../common/json';
import { callPublicClient } from './call';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (bzzChainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const json = await jsonGet(bzzChainId);
	if (!('batchId' in json)) utilsError(`callPostageBatches: No batchId in json ${bzzChainId})`);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const callPostageBatchesLegacy = async (bzzChainId: number): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const json = await jsonGet(bzzChainId);
	if (!('batchId' in json))
		utilsError(`callPostageBatchesLegacy: No batchId in json ${bzzChainId})`);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const callPostageLastPrice = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	const json = await jsonGet(bzzChainId);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const callPostageRemainingBalance = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	const json = await jsonGet(bzzChainId);
	if (!('batchId' in json))
		utilsError(`callPostageRemainingBalance: No batchId in json ${bzzChainId})`);

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
