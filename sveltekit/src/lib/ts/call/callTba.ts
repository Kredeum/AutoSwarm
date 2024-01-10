import type { Address, Hex } from 'viem';
import { autoSwarmAccountAbi } from '../constants/abis';

import { callIsContract, callPublicClient } from './call';
import { ZERO_BYTES32 } from '../constants/constants';

const callTbaBzzStampId = async (bzzChainId: number, tba: Address | undefined): Promise<Hex> => {
	if (!(tba && (await callIsContract(bzzChainId, tba)))) return ZERO_BYTES32;

	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'stampId'
	});
};

const callTbaSwarmHash = async (
	bzzChainId: number,
	tba: Address | undefined
): Promise<Hex | undefined> => {
	if (!(tba && (await callIsContract(bzzChainId, tba)))) return;

	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'swarmHash'
	});
};

const callTbaSwarmSize = async (bzzChainId: number, tba: Address | undefined): Promise<bigint> => {
	if (!(tba && (await callIsContract(bzzChainId, tba)))) return 0n;

	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'swarmSize'
	});
};

const callTbaToken = async (
	bzzChainId: number,
	tba: Address
): Promise<readonly [bigint, Address, bigint]> => {
	const publicClient = await callPublicClient(bzzChainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'token'
	});
};

export { callTbaSwarmHash, callTbaSwarmSize, callTbaBzzStampId, callTbaToken };
