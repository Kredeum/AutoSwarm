import type { Address, Hex } from 'viem';
import { callPublicClient } from './call';
import { addressesGetField } from '../common/addresses';
import { erc6551RegistryAbi } from '../constants/abis';
import { SALT } from '../constants/constants';

const callRegistryAccount = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<Address> => {
	// console.info('callRegistryAccount start', bzzChainId, nftChainId, nftCollection, nftTokenId);

	const publicClient = await callPublicClient(bzzChainId);

	const erc6551Registry = addressesGetField(bzzChainId, 'ERC6551Registry');
	const autoSwarmAccount = addressesGetField(bzzChainId, 'AutoSwarmAccount');

	const tba = await publicClient.readContract({
		address: erc6551Registry,
		abi: erc6551RegistryAbi,
		functionName: 'account',
		args: [autoSwarmAccount, SALT, BigInt(nftChainId), nftCollection, nftTokenId]
	});

	return tba;
};

export { callRegistryAccount };
