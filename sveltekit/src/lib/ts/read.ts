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

	return Number(bytecode?.length || 0n) > 0;
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
	const tokenId = await readLastTokenId(publicClient);

	return await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [tokenId]
	});
};

const readNftMetadata = async (publicClient: PublicClient): Promise<NftMetadata> => {
	const json = await readJson(publicClient);
	const tokenId = await readLastTokenId(publicClient);

	const tokenURI = await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'tokenURI',
		args: [tokenId]
	});
	const urlHash = tokenURI.replace('swarm://', SWARM_GATEWAY);
	const data = await fetch(urlHash as string);
	const nftMetadataJson = await data.json();

	return {
		name: nftMetadataJson.name,
		image: nftMetadataJson.image,
		description: nftMetadataJson.description,
		tokenId: String(tokenId),
		address: json.NFTCollection
	};
};

const readAccount = async (publicClient: PublicClient): Promise<Address> => {
	const chainId = await readChainId(publicClient);
	const json = await readJson(publicClient);
	const tokenId = await readLastTokenId(publicClient);

	const args: [`0x${string}`, bigint, `0x${string}`, bigint, bigint] = [
		json.AutoSwarmAccount as Address,
		BigInt(chainId),
		json.NFTCollection as Address,
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

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readLastTokenId = async (publicClient: PublicClient): Promise<bigint> => {
	const json = await readJson(publicClient);
	if (!('batchId' in json))
		throw Error(`No batchId in json ${String(await readChainId(publicClient))})`);

	const data = await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return data;
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
	readLastTokenId,
	readBatchLegacy,
	readNftMetadata,
	readRemainingBalance
};
