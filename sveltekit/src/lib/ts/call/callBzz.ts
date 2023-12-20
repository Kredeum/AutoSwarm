import type { Address } from 'viem';
import { erc20Abi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';

const callBzzBalance = async (
	tbaChainId: number,
	account?: Address
): Promise<bigint | undefined> => {
	if (account === undefined) return;
	const publicClient = await callPublicClient(tbaChainId);

	return await publicClient.readContract({
		address: (await addressesGetField(tbaChainId, 'BzzToken')) as Address,
		abi: erc20Abi,
		functionName: 'balanceOf',
		args: [account]
	});
};

export { callBzzBalance };
