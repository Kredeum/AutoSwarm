import type { Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';
import type { StampType } from '../constants/types';

const callMarketGetStampsCount = async (bzzChainId: number): Promise<number> => {
	const publicClient = await callPublicClient(bzzChainId);

	return Number(
		await publicClient.readContract({
			address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
			abi: autoSwarmMarketAbi,
			functionName: 'getStampsCount'
		})
	);
};

const callMarketGetAllStampsIds = async (bzzChainId: number, limit = 100): Promise<Hex[]> => {
	const CALL_LIMIT = 3;

  const stampsCount = await callMarketGetStampsCount(bzzChainId);
	console.info('callMarketGetAllStampsIds  IN', stampsCount, limit);

	const stampsIds: Hex[] = [];

	for (let n = 0; n * CALL_LIMIT < stampsCount && stampsIds.length < limit; n++) {
		const newStampsIds = await callMarketGetStampsIds(bzzChainId, n * CALL_LIMIT, CALL_LIMIT);
		stampsIds.push(...newStampsIds);
	}

	console.info('callMarketGetAllStampsIds OUT', stampsIds.length);
	return stampsIds;
};

const callMarketGetAllStampsIdsToAttach = async (
	bzzChainId: number,
	limit = 3,
	callLimit = 3
): Promise<Hex[]> => {
	const stampsCount = await callMarketGetStampsCount(bzzChainId);
	// console.info('callMarketGetAllStampsIdsToAttach  IN', stampsCount);

	const stampsIds: Hex[] = [];

	for (let n = 0; n * callLimit < stampsCount && stampsIds.length < limit; n++) {
		const newStampsIds = await callMarketGetStampsIdsToAttach(bzzChainId, n * callLimit, callLimit);
		stampsIds.push(...newStampsIds);
	}

	// console.info('callMarketGetAllStampsIdsToAttach OUT', stampsIds.length);
	return stampsIds;
};

const callMarketGetStampsIds = async (
	bzzChainId: number,
	skip = 0,
	limit = 3
): Promise<readonly Hex[]> => {
	// console.info('callMarketGetStampsIds  IN', skip, limit);

	const publicClient = await callPublicClient(bzzChainId);

	const stampsIds = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'getStampsIds',
		args: [BigInt(skip), BigInt(limit)]
	});

	// console.info('callMarketGetStampsIdscallMarketGetStampsIds OUT', stampsIds.length);
	return stampsIds;
};
const callMarketGetStampsIdsToAttach = async (
	bzzChainId: number,
	skip = 0,
	limit = 3
): Promise<readonly Hex[]> => {
	// console.info('callMarketGetStampsIdsToAttach  IN', skip, limit);

	const publicClient = await callPublicClient(bzzChainId);

	const stampsIds = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'getStampsIdsToAttach',
		args: [BigInt(skip), BigInt(limit)]
	});

	// console.info('callMarketGetStampsIdsToAttach OUT', stampsIds.length);
	return stampsIds;
};

const callMarketGetStampRemainingBalance = async (
	bzzChainId: number,
	stampId: Hex
): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'getStampRemainingBalance',
		args: [stampId]
	});
};

const callMarketGetStamp = async (bzzChainId: number, stampId: Hex): Promise<StampType> => {
	const publicClient = await callPublicClient(bzzChainId);

	const [swarmHash, swarmSize, batchId, normalisedBalance] = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'stamps',
		args: [stampId]
	});

	return { swarmHash, swarmSize, batchId, normalisedBalance };
};

export {
	callMarketGetStamp,
	callMarketGetStampRemainingBalance,
	callMarketGetStampsCount,
	callMarketGetStampsIds,
	callMarketGetStampsIdsToAttach,
	callMarketGetAllStampsIds,
	callMarketGetAllStampsIdsToAttach
};
