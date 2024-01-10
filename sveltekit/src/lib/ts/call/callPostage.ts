import type { Address, Hex } from 'viem';
import { postageStampAbi, postageStampAbiBatcheslegacy } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';
import { BUCKET_DEPTH } from '../constants/constants';
import { utilsIsNullBytes32 } from '../common/utils';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (
	bzzChainId: number,
	batchId: Hex
): Promise<[Address, number, number, boolean, bigint, bigint]> => {
	// console.info('callPostageBatches', batchId);

	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, bucketDepth, immutableFlag, normalisedBalance, lastUpdatedBlockNumber] =
		await publicClient.readContract({
			address: addressesGetField(bzzChainId, 'PostageStamp'),
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
	// console.info('callPostageBatchesLegacy', batchId);
	const publicClient = await callPublicClient(bzzChainId);

	const [owner, depth, immutableFlag, normalisedBalance] = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'PostageStamp'),
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [batchId]
	});

	return [owner, depth, BUCKET_DEPTH, immutableFlag, normalisedBalance, undefined];
};

const callPostageCurrentTotalOutPayment = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'PostageStamp'),
		abi: postageStampAbi,
		functionName: 'currentTotalOutPayment'
	});
};

const callPostageLastPrice = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'PostageStamp'),
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const callPostageRemainingBalance = async (
	bzzChainId: number,
	batchId: Hex
): Promise<bigint | undefined> => {
	if (utilsIsNullBytes32(batchId)) return;

	const publicClient = await callPublicClient(bzzChainId);

	const data = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'PostageStamp'),
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
