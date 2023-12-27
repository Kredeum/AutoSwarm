import type { Address, Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';

const callMarketCurrentBatchId = async (bzzChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket') as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchId'
	});
};

const callMarketCurrentSwarmNode = async (bzzChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket') as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'currentSwarmNode'
	});
};

const callMarketNewBatchNeeded = async (bzzChainId: number): Promise<boolean> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'AutoSwarmMarket') as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'newBatchNeeded'
	});
};

const callMarketGetStampsCount = async (bzzChainId: number): Promise<number> => {
	const publicClient = await callPublicClient(bzzChainId);

	return Number(
		await publicClient.readContract({
			address: addressesGetField(bzzChainId, 'AutoSwarmMarket') as Address,
			abi: autoSwarmMarketAbi,
			functionName: 'getStampsCount'
		})
	);
};

export {
	callMarketCurrentBatchId,
	callMarketNewBatchNeeded,
	callMarketCurrentSwarmNode,
	callMarketGetStampsCount
};
