import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';
import { utilsError } from '../common/utils';

import { jsonGet, jsonGetField } from '../common/json';
import { callPublicClient } from './call';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (
	bzzChainId: number,
	batchId: Hex
): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [batchId]
	});

	return [owner, depth, rBal];
};

const callPostageBatchesLegacy = async (
	bzzChainId: number,
	batchId: Hex
): Promise<[Address, number, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [batchId]
	});

	return [owner, depth, rBal];
};

const callPostageLastPrice = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const callPostageRemainingBalance = async (bzzChainId: number, batchId: Hex): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	const data = await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbi,
		functionName: 'remainingBalance',
		args: [batchId]
	});

	return data;
};

export {
	callPostageBatches,
	callPostageBatchesLegacy,
	callPostageLastPrice,
	callPostageRemainingBalance
};
