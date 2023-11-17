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
	nftTokenId: bigint
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
	const nftMetadataJson = (await fetchJson(tokenUriAlt)) as NftMetadata;
	if (!nftMetadataJson)
		throw Error(`NFT metadata lost!\nFollowing tokenURI not available\n${tokenUri}`);

	const [imageAlt, imageType] = await fetchAltUrl(nftMetadataJson.image);
	if (!fetchUrlOk(imageAlt))
		throw Error(`NFT image lost!\nFollowing image not available\n${nftMetadataJson.image}`);

	nftMetadataJson.tokenUri = tokenUri;
	nftMetadataJson.tokenUriType = tokenUriType;
	nftMetadataJson.tokenUriAlt = tokenUriAlt;
	nftMetadataJson.imageType = imageType;
	nftMetadataJson.imageAlt = imageAlt;
	nftMetadataJson.tokenId = String(nftTokenId);
	nftMetadataJson.address = nftCollection;

	return nftMetadataJson;
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
