import type { Address, Hex } from 'viem';
import { callPublicClient } from './call';
import { addressesGetField } from '../common/addresses';
import { erc6551RegistryAbi } from '../constants/abis';
import { SALT } from '../constants/constants';

const callRegistryAccount = async (
	tbaChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<Address> => {
	// console.info('callRegistryAccount start', tbaChainId, nftChainId, nftCollection, nftTokenId);

	const publicClient = await callPublicClient(tbaChainId);

	const erc6551Registry = (await addressesGetField(tbaChainId, 'ERC6551Registry')) as Address;
	const autoSwarmAccount = (await addressesGetField(tbaChainId, 'AutoSwarmAccount')) as Address;

	const tba = await publicClient.readContract({
		address: erc6551Registry,
		abi: erc6551RegistryAbi,
		functionName: 'account',
		args: [autoSwarmAccount, SALT, BigInt(nftChainId), nftCollection, nftTokenId]
	});

	return tba;
};

export { callRegistryAccount };
