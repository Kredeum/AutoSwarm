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

const callMarketGetAllStampIds = async (bzzChainId: number, limit = 100): Promise<Hex[]> => {
	const CALL_LIMIT = 3;

	const stampsCount = await callMarketGetStampsCount(bzzChainId);
	console.info('callMarketGetAllStampIds  IN', stampsCount, limit);

	const stampIds: Hex[] = [];

	for (let n = 0; n * CALL_LIMIT < stampsCount && stampIds.length < limit; n++) {
		const newStampIds = await callMarketGetStampIds(bzzChainId, n * CALL_LIMIT, CALL_LIMIT);
		stampIds.push(...newStampIds);
	}

	console.info('callMarketGetAllStampIds OUT', stampIds.length);
	return stampIds;
};

const callMarketGetAllStampIdsToAttach = async (
	bzzChainId: number,
	limit = 3,
	callLimit = 3
): Promise<Hex[]> => {
	const stampsCount = await callMarketGetStampsCount(bzzChainId);
	// console.info('callMarketGetAllStampIdsToAttach  IN', stampsCount);

	const stampIds: Hex[] = [];

	for (let n = 0; n * callLimit < stampsCount && stampIds.length < limit; n++) {
		const newStampIds = await callMarketGetStampIdsToAttach(bzzChainId, n * callLimit, callLimit);
		stampIds.push(...newStampIds);
	}

	// console.info('callMarketGetAllStampIdsToAttach OUT', stampIds.length);
	return stampIds;
};

const callMarketGetStampIds = async (
	bzzChainId: number,
	skip = 0,
	limit = 3
): Promise<readonly Hex[]> => {
	// console.info('callMarketGetStampIds  IN', skip, limit);

	const publicClient = await callPublicClient(bzzChainId);

	const stampIds = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'getStampIds',
		args: [BigInt(skip), BigInt(limit)]
	});

	// console.info('callMarketGetStampIdscallMarketGetStampIds OUT', stampIds.length);
	return stampIds;
};
const callMarketGetStampIdsToAttach = async (
	bzzChainId: number,
	skip = 0,
	limit = 3
): Promise<readonly Hex[]> => {
	// console.info('callMarketGetStampIdsToAttach  IN', skip, limit);

	const publicClient = await callPublicClient(bzzChainId);

	const stampIds = await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'getStampIdsToAttach',
		args: [BigInt(skip), BigInt(limit)]
	});

	// console.info('callMarketGetStampIdsToAttach OUT', stampIds.length);
	return stampIds;
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
	callMarketGetStampIds,
	callMarketGetStampIdsToAttach,
	callMarketGetAllStampIds,
	callMarketGetAllStampIdsToAttach
};
