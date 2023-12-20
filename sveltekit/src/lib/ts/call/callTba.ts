import type { Address, Hex } from 'viem';
import { autoSwarmAccountAbi } from '../constants/abis';

import { callIsContract, callPublicClient } from './call';
import { ZERO_BYTES32 } from '../constants/constants';

const callTbaBzzStampId = async (tbaChainId: number, tba: Address | undefined): Promise<Hex> => {
	if (!(tba && (await callIsContract(tbaChainId, tba)))) return ZERO_BYTES32;

	const publicClient = await callPublicClient(tbaChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'stampId'
	});
};

const callTbaBzzHash = async (
	tbaChainId: number,
	tba: Address | undefined
): Promise<Hex | undefined> => {
	if (!(tba && (await callIsContract(tbaChainId, tba)))) return;

	const publicClient = await callPublicClient(tbaChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'bzzHash'
	});
};

const callTbaBzzSize = async (tbaChainId: number, tba: Address | undefined): Promise<bigint> => {
	if (!(tba && (await callIsContract(tbaChainId, tba)))) return 0n;

	const publicClient = await callPublicClient(tbaChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'bzzSize'
	});
};

export { callTbaBzzHash, callTbaBzzSize, callTbaBzzStampId };
