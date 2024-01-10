import type { Address } from 'viem';
import { erc20Abi } from '../constants/abis';

import { addressesGetField } from '../common/addresses';
import { callPublicClient } from './call';

const callBzzBalance = async (
	bzzChainId: number,
	account?: Address
): Promise<bigint | undefined> => {
	if (account === undefined) return;
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: addressesGetField(bzzChainId, 'BzzToken'),
		abi: erc20Abi,
		functionName: 'balanceOf',
		args: [account]
	});
};

export { callBzzBalance };
