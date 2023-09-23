import type { Address, Hex, PublicClient } from 'viem';
import {
	bzzTokenAbi,
	postageStampAbi,
	postageStampAbiBatcheslegacy,
	erc6551RegistryAbi,
	erc721Abi
} from './abis';
import { getJson } from '$lib/ts/get';
import { SALT, SWARM_GATEWAY, type NftMetadata } from '$lib/ts/constants';
import type { ChainIdInJson } from '$lib/ts/get';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const readIsContract = async (publicClient: PublicClient, address: Address): Promise<boolean> => {
	if (address == '0x0') return false;

	const bytecode = await publicClient.getBytecode({ address });

	const len = Number(bytecode?.length || 0n);
	console.log('readIsContract ~ len:', len);

	return len > 0;
};

const readChainId = async (publicClient: PublicClient) => {
	return await publicClient.getChainId();
};

const readJson = async (publicClient: PublicClient) => {
	const chainId: ChainIdInJson = await readChainId(publicClient);
	return getJson(chainId);
};

const readLastPrice = async (publicClient: PublicClient): Promise<bigint> => {
	const json = await readJson(publicClient);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const readBzzBalance = async (publicClient: PublicClient, address: Address): Promise<bigint> => {
	if (address == '0x0') return 0n;

	const json = await readJson(publicClient);

	return await publicClient.readContract({
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'balanceOf',
		args: [address]
	});
};

const readNftOwner = async (publicClient: PublicClient): Promise<Address> => {
	const json = await readJson(publicClient);

	return await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [BigInt(json.tokenId)]
	});
};

const readNftMetadata = async (publicClient: PublicClient): Promise<NftMetadata | undefined> => {
	const json = await readJson(publicClient);
	if (!('tokenId' in json)) throw Error('No tokenId in json');

	const tokenURI = await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'tokenURI',
		args: [BigInt(json.tokenId)]
	});
	const urlHash = tokenURI.replace('swarm://', SWARM_GATEWAY);
	const data = await fetch(urlHash as string);
	const nftMetadataJson = await data.json();
	console.log('readNftMetadata ~ nftMetadataJson:', nftMetadataJson);

	return {
		name: nftMetadataJson.name,
		image: nftMetadataJson.image,
		description: nftMetadataJson.description,
		tokenId: json.tokenId,
		address: json.NFTCollection
	};
};

const readAccount = async (publicClient: PublicClient): Promise<Address> => {
	const chainId = await readChainId(publicClient);
	const json = await readJson(publicClient);
	if (!('tokenId' in json)) throw Error('No tokenId in json');

	const args: [`0x${string}`, bigint, `0x${string}`, bigint, bigint] = [
		json.AutoSwarmAccount as Address,
		BigInt(chainId),
		json.NFTCollection as Address,
		BigInt(json.tokenId),
		SALT
	];

	return await publicClient.readContract({
		address: json.ERC6551Registry as Address,
		abi: erc6551RegistryAbi,
		functionName: 'account',
		args
	});
};

const readBatchLegacy = async (publicClient: PublicClient): Promise<[Address, number, bigint]> => {
	const json = await readJson(publicClient);
	if (!('batchId' in json))
		throw Error(`No batchId in json ${String(await readChainId(publicClient))})`);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readBatchNew = async (publicClient: PublicClient): Promise<[Address, number, bigint]> => {
	const json = await readJson(publicClient);
	if (!('batchId' in json))
		throw Error(`No batchId in json ${String(await readChainId(publicClient))})`);

	console.log('readBatchNew ~ json:', json);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readRemainingBalance = async (publicClient: PublicClient): Promise<bigint> => {
	const json = await readJson(publicClient);
	if (!('batchId' in json))
		throw Error(`No batchId in json ${String(await readChainId(publicClient))})`);

	const data = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'remainingBalance',
		args: [json.batchId as Hex]
	});
	console.log('readRemainingBalance ~ data:', data);

	return data;
};

export {
	readJson,
	readChainId,
	readAccount,
  readNftOwner,
	readBatchNew,
	readLastPrice,
	readIsContract,
	readBzzBalance,
	readBatchLegacy,
	readNftMetadata,
	readRemainingBalance
};
