import type { Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';
import type { StampType } from '../constants/types';

const callMarketCurrentBatchId = async (bzzChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchId'
	});
};

const callMarketCurrentSwarmNode = async (bzzChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'currentSwarmNode'
	});
};

const callMarketNewBatchNeeded = async (bzzChainId: number): Promise<boolean> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'newBatchNeeded'
	});
};

const callMarketCurrentBatchFilling = async (bzzChainId: number): Promise<bigint> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket'),
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchFilling'
	});
};

export {
	callMarketNewBatchNeeded,
	callMarketCurrentSwarmNode,
	callMarketCurrentBatchId,
	callMarketCurrentBatchFilling
};
