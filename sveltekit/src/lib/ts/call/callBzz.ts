import type { Address } from 'viem';
import { erc20Abi } from '../constants/abis';

import { jsonGetField } from '../constants/json';
import { callPublicClient } from './call';

const callBzzBalance = async (chainId: number, account: Address): Promise<bigint | undefined> => {
	if (account === undefined) return;
	const publicClient = await callPublicClient(chainId);

	return await publicClient.readContract({
		address: (await jsonGetField(chainId, 'BzzToken')) as Address,
		abi: erc20Abi,
		functionName: 'balanceOf',
		args: [account]
	});
};

export { callBzzBalance };
