import type { Address, Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { jsonGetField } from '../constants/json';
import { callPublicClient } from './call';

const callMarketCurrentBatchId = async (chainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(chainId);

	return await publicClient.readContract({
		address: (await jsonGetField(chainId, 'AutoSwarmMarket')) as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchId'
	});
};

export { callMarketCurrentBatchId };
