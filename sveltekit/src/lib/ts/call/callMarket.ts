import type { Address, Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';

const callMarketCurrentBatchId = async (bzzChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: (await addressesGetField(bzzChainId, 'AutoSwarmMarket')) as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchId'
	});
};

export { callMarketCurrentBatchId };
