import type { Address } from 'viem';
import { erc6551RegistryAbi, erc721Abi } from '../constants/abis';
import { type NftMetadata, SALT } from '$lib/ts/constants/constants';
import { utilsError } from '../swarm/utils';
import { readPublicClient } from './read';
import { jsonGet } from '../constants/json';
import { fetchJson, fetchUrlAlt } from '../offchain/fetch';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const readNftOwner = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<Address> => {
	const publicClient = await readPublicClient(chainId);

	return await publicClient.readContract({
		address: collection,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [tokenId]
	});
};

const readNftMetadata = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<NftMetadata> => {
	// console.info('readNftMetadata:', chainId, collection, tokenId);

	const publicClient = await readPublicClient(chainId);

	const tokenURI = await publicClient.readContract({
		address: collection,
		abi: erc721Abi,
		functionName: 'tokenURI',
		args: [tokenId]
	});
	const tokenURIAlt = await fetchUrlAlt(tokenURI);
	const nftMetadataJson = (await fetchJson(tokenURIAlt)) as unknown as NftMetadata;

	return {
		name: nftMetadataJson.name,
		image: nftMetadataJson.image,
		description: nftMetadataJson.description,
		tokenId: String(tokenId),
		address: collection
	};
};

const readNftImage = async (nftMetadataJson: NftMetadata): Promise<string> =>
	await fetchUrlAlt(nftMetadataJson.image);

const readNftTotalSupply = async (chainId: number, collection: Address): Promise<bigint> => {
	const publicClient = await readPublicClient(chainId);

	const json = await jsonGet(chainId);
	if (!('batchId' in json)) utilsError(`No batchId in json ${chainId})`);

	const data = await publicClient.readContract({
		address: collection,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return data;
};

const readNftTBAccount = async (
	chainId: number,
	collection: Address,
	tokenId: bigint
): Promise<Address> => {
	const publicClient = await readPublicClient(chainId);

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

export { readNftOwner, readNftTBAccount, readNftTotalSupply, readNftMetadata, readNftImage };
