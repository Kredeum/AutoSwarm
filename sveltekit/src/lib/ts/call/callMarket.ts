import type { Address, Hex } from 'viem';
import { autoSwarmMarketAbi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';

const callMarketCurrentBatchId = async (tbaChainId: number): Promise<Hex> => {
	const publicClient = await callPublicClient(tbaChainId);

	return await publicClient.readContract({
		address: (await addressesGetField(tbaChainId, 'AutoSwarmMarket')) as Address,
		abi: autoSwarmMarketAbi,
		functionName: 'currentBatchId'
	});
};

export { callMarketCurrentBatchId };
