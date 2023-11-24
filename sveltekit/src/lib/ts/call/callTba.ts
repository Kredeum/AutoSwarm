import type { Address, Hex } from 'viem';
import { autoSwarmAccountAbi } from '../constants/abis';

import { callPublicClient } from './call';

const callTbaTokenUri = async (chainId: number, tba: Address): Promise<URL | undefined> => {
	if (tba === undefined) return;
	const bzzHash = await callTbaBzzHash(chainId, tba);

	return new URL(`bzz://${bzzHash}`);
};

const callTbaBzzHash = async (chainId: number, tba: Address): Promise<Hex | undefined> => {
	if (tba === undefined) return;
	const publicClient = await callPublicClient(chainId);

	return await publicClient.readContract({
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'bzzHash'
	});
};

export { callTbaTokenUri, callTbaBzzHash };
