import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';

import { jsonGetField } from '../common/json';
import { callPublicClient } from './call';
import { BUCKET_DEPTH } from '../constants/constants';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (
	bzzChainId: number,
	batchId: Hex
): Promise<[Address, number, number, boolean, bigint, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, bucketDepth, immutableFlag, normalisedBalance, lastUpdatedBlockNumber] =
		await publicClient.readContract({
			address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
			abi: postageStampAbi,
			functionName: 'batches',
			args: [batchId]
		});

	return [owner, depth, bucketDepth, immutableFlag, normalisedBalance, lastUpdatedBlockNumber];
};

// OLD POSTAGE VERSION < 0.6
const callPostageBatchesLegacy = async (
	bzzChainId: number,
	batchId: Hex
): Promise<[Address, number, number, boolean, bigint, undefined]> => {
	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, immutableFlag, normalisedBalance] = await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [batchId]
	});

	return [owner, depth, BUCKET_DEPTH, immutableFlag, normalisedBalance, undefined];
};

const callPostageCurrentTotalOutPayment = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: (await jsonGetField(bzzChainId, 'PostageStamp')) as Address,
		abi: postageStampAbi,
		functionName: 'currentTotalOutPayment'
	});
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
	callPostageRemainingBalance,
	callPostageCurrentTotalOutPayment
};
