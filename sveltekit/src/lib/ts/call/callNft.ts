import type { Address } from 'viem';
import { erc1155Abi, erc165Abi, erc6551RegistryAbi, erc721Abi } from '../constants/abis';
import { type NftMetadata, SALT } from '$lib/ts/constants/constants';
import { callPublicClient } from './call';
import { jsonGet } from '../constants/json';
import { fetchJson, fetchUrlAlt, fetchUrlOk } from '../fetch/fetch';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callNftOwner = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<Address> => {
	const publicClient = await callPublicClient(chainId);

	return await publicClient.readContract({
		address: collection,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [tokenId]
	});
};

const callNftMetadata = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<NftMetadata> => {
	// console.info('callNftMetadata:', chainId, collection, tokenId);

	const publicClient = await callPublicClient(chainId);

	const nftIs1155 = await callNftIs1155(chainId, collection);

	let tokenUri: string;
	if (nftIs1155) {
		tokenUri = await publicClient.readContract({
			address: collection,
			abi: erc1155Abi,
			functionName: 'uri',
			args: [tokenId]
		});
	} else {
		tokenUri = await publicClient.readContract({
			address: collection,
			abi: erc721Abi,
			functionName: 'tokenURI',
			args: [tokenId]
		});
	}
	const [tokenUriAlt, tokenUriType] = await fetchUrlAlt(tokenUri);
	const nftMetadataJson = (await fetchJson(tokenUriAlt)) as NftMetadata;
	if (!nftMetadataJson)
		throw Error(`NFT metadata lost!\nFollowing tokenURI not available\n${tokenUri}`);

	const [imageAlt, imageType] = await fetchUrlAlt(nftMetadataJson.image);
	if (!fetchUrlOk(imageAlt))
		throw Error(`NFT image lost!\nFollowing image not available\n${nftMetadataJson.image}`);

	nftMetadataJson.tokenUri = tokenUri;
	nftMetadataJson.tokenUriType = tokenUriType;
	nftMetadataJson.tokenUriAlt = tokenUriAlt;
	nftMetadataJson.imageType = imageType;
	nftMetadataJson.imageAlt = imageAlt;
	nftMetadataJson.tokenId = String(tokenId);
	nftMetadataJson.address = collection;

	return nftMetadataJson;
};

const callNftIs1155 = async (chainId: number, collection: Address): Promise<boolean> => {
	const publicClient = await callPublicClient(chainId);

	const data = await publicClient.readContract({
		address: collection,
		abi: erc165Abi,
		functionName: 'supportsInterface',
		args: ['0xd9b67a26']
	});

	return data;
};

const callNftTotalSupply = async (chainId: number, collection: Address): Promise<bigint> => {
	const publicClient = await callPublicClient(chainId);

	const data = await publicClient.readContract({
		address: collection,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return data;
};

const callNftTBAccount = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<Address> => {
	const publicClient = await callPublicClient(chainId);

	const json = await jsonGet(chainId);

	const args: [`0x${string}`, bigint, `0x${string}`, bigint, bigint] = [
		json.AutoSwarmAccount as Address,
		BigInt(chainId),
		collection,
		tokenId,
		SALT
	];

	return await publicClient.readContract({
		address: json.ERC6551Registry as Address,
		abi: erc6551RegistryAbi,
		functionName: 'account',
		args
	});
};

export { callNftOwner, callNftTBAccount, callNftTotalSupply, callNftMetadata, callNftIs1155 };
