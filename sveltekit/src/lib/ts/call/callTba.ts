import type { Address, Hex } from 'viem';
import { autoSwarmAccountAbi } from '../constants/abis';

import { callIsContract, callPublicClient } from './call';
import { UNDEFINED_DATA, ZERO_BYTES32 } from '../constants/constants';


const callTbaStampId = async (bzzChainId: number, tba: Address | undefined): Promise<Hex> => {
	if (!(tba && (await callIsContract(bzzChainId, tba)))) return ZERO_BYTES32;

	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'stampId'
	});
};
const callTbaBzzHash = async (bzzChainId: number, tba: Address | undefined): Promise<Hex> => {
	if (!(tba && (await callIsContract(bzzChainId, tba)))) return ZERO_BYTES32;

	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'bzzHash'
	});
};

export { callTbaBzzHash, callTbaStampId };
