import type { Address } from 'viem';
import { erc1155Abi, erc165Abi, erc721Abi } from '../constants/abis';
import { callPublicClient } from './call';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callNftOwner = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<Address> => {
	const publicClient = await callPublicClient(nftChainId);

	return await publicClient.readContract({
		address: nftCollection,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [nftTokenId]
	});
};

const callNftTokenUri = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<string> => {
	// console.info('callNftTokenUri', nftChainId, nftCollection, nftTokenId);

	if (nftChainId === 1 && nftCollection === '0x5c211B8E4f93F00E2BD68e82F4E00FbB3302b35c')
		return `ipfs://QmRX12SKvyQh46PfzPMSwgFYGv81Fx8rXFbFXseFi23omy/${nftTokenId}.json`;

	const publicClient = await callPublicClient(nftChainId);

	const nftIs1155 = await callNftIs1155(nftChainId, nftCollection);

	const nftMetadataUri = nftIs1155
		? await publicClient.readContract({
				address: nftCollection,
				abi: erc1155Abi,
				functionName: 'uri',
				args: [nftTokenId]
			})
		: await publicClient.readContract({
				address: nftCollection,
				abi: erc721Abi,
				functionName: 'tokenURI',
				args: [nftTokenId]
			});

	// console.info('callNftTokenUri', nftMetadataUri.toString());
	return nftMetadataUri;
};

const callNftIs1155 = async (nftChainId: number, nftCollection: Address): Promise<boolean> => {
	// console.info('callNftIs1155', nftChainId, nftCollection);

	const publicClient = await callPublicClient(nftChainId);

	const isErc1155 = await publicClient.readContract({
		address: nftCollection,
		abi: erc165Abi,
		functionName: 'supportsInterface',
		args: ['0xd9b67a26']
	});

	// console.info('callNftIs1155', isErc1155);
	return isErc1155;
};

const callNftTotalSupply = async (nftChainId: number, nftCollection: Address): Promise<bigint> => {
	const publicClient = await callPublicClient(nftChainId);

	const totalSupply = await publicClient.readContract({
		address: nftCollection,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return totalSupply;
};

export { callNftOwner, callNftTotalSupply, callNftTokenUri, callNftIs1155 };
