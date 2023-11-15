import type { Address, Hex } from 'viem';
import { autoSwarmAbi } from '../constants/abis';

import { jsonGetField } from '../constants/json';
import { readPublicClient } from './read';

const readMarketCurrentBatchId = async (chainId: number): Promise<Hex> => {
	const publicClient = await readPublicClient(chainId);

	return await publicClient.readContract({
		address: (await jsonGetField(chainId, 'AutoSwarmMarket')) as Address,
		abi: autoSwarmAbi,
		functionName: 'currentBatchId'
	});
};

export { readMarketCurrentBatchId };
