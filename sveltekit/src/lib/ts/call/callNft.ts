import type { Address } from 'viem';
import { erc1155Abi, erc165Abi, erc721Abi } from '../constants/abis';
import type { NftMetadata } from '$lib/ts/constants/constants';
import { callPublicClient } from './call';
import { fetchJson, fetchAltUrl, fetchUrlOk } from '../fetch/fetch';

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

const callNftMetadata = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint,
	nftMetadata?: NftMetadata
): Promise<NftMetadata> => {
	// console.info('callNftMetadata:', nftChainId, nftCollection, nftTokenId);

	const publicClient = await callPublicClient(nftChainId);

	const nftIs1155 = await callNftIs1155(nftChainId, nftCollection);

	let tokenUri: string;
	if (nftIs1155) {
		tokenUri = await publicClient.readContract({
			address: nftCollection,
			abi: erc1155Abi,
			functionName: 'uri',
			args: [nftTokenId]
		});
	} else {
		tokenUri = await publicClient.readContract({
			address: nftCollection,
			abi: erc721Abi,
			functionName: 'tokenURI',
			args: [nftTokenId]
		});
	}

	const [tokenUriAlt, tokenUriType] = await fetchAltUrl(tokenUri);
	nftMetadata ||= (await fetchJson(tokenUriAlt)) as NftMetadata;
	if (!nftMetadata)
		throw Error(`NFT metadata lost!\nFollowing tokenURI not available\n${tokenUri}`);

	const [imageAlt, imageType] = await fetchAltUrl(nftMetadata.image);
	if (!fetchUrlOk(imageAlt))
		throw Error(`NFT image lost!\nFollowing image not available\n${nftMetadata.image}`);

	nftMetadata.tokenUri = tokenUri;
	nftMetadata.tokenUriType = tokenUriType;
	if (tokenUriAlt) nftMetadata.tokenUriAlt = tokenUriAlt;
	nftMetadata.imageType = imageType;
	if (imageAlt) nftMetadata.imageAlt = imageAlt;
	nftMetadata.tokenId = String(nftTokenId);
	nftMetadata.address = nftCollection;

	return nftMetadata;
};

const callNftIs1155 = async (nftChainId: number, nftCollection: Address): Promise<boolean> => {
	const publicClient = await callPublicClient(nftChainId);

	const data = await publicClient.readContract({
		address: nftCollection,
		abi: erc165Abi,
		functionName: 'supportsInterface',
		args: ['0xd9b67a26']
	});

	return data;
};

const callNftTotalSupply = async (nftChainId: number, nftCollection: Address): Promise<bigint> => {
	const publicClient = await callPublicClient(nftChainId);

	const data = await publicClient.readContract({
		address: nftCollection,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return data;
};

export { callNftOwner, callNftTotalSupply, callNftMetadata, callNftIs1155 };
