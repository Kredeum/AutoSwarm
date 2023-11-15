import type { Address } from 'viem';
import { bzzTokenAbi } from '../constants/abis';

import { jsonGetField } from '../constants/json';
import { readPublicClient } from './read';

const readBzzBalance = async (chainId: number, account: Address): Promise<bigint | undefined> => {
	if (account === undefined) return;
	const publicClient = await readPublicClient(chainId);

	return await publicClient.readContract({
		address: (await jsonGetField(chainId, 'BzzToken')) as Address,
		abi: bzzTokenAbi,
		functionName: 'balanceOf',
		args: [account]
	});
};

export { readBzzBalance };
