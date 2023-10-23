import {
	http,
	type Chain,
	type Address,
	type Block,
	type Hex,
	type PublicClient,
	createPublicClient
} from 'viem';
import {
	bzzTokenAbi,
	postageStampAbi,
	postageStampAbiBatcheslegacy,
	erc6551RegistryAbi,
	erc721Abi
} from './abis';
import { getJson } from '$lib/ts/get';
import { SALT, SWARM_GATEWAY, type NftMetadata, SEPOLIA_RPC } from '$lib/ts/constants';
import type { ChainIdInJson } from '$lib/ts/get';
import { utilsError } from './utils';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

// publicClients Map
const _publicClients: Map<number, PublicClient> = new Map();

const readPublicClient = async (chain: Chain): Promise<PublicClient> => {
	const publicClient = _publicClients.get(chain.id);
	if (publicClient) return publicClient;

	const transport = chain.id == 11155111 ? http(SEPOLIA_RPC) : http();

	return createPublicClient({ chain, transport });
};

const readBlock = async (chain: Chain, blockNumber?: bigint): Promise<Block> => {
	const publicClient = await readPublicClient(chain);

	const param = blockNumber ? { blockNumber } : {};

	return await publicClient.getBlock(param);
};

const readIsContract = async (chain: Chain, address: Address): Promise<boolean> => {
	if (address == '0x0') return false;
	const publicClient = await readPublicClient(chain);

	const bytecode = await publicClient.getBytecode({ address });

	return Number(bytecode?.length || 0n) > 0;
};

const readChainId = async (chain: Chain) => {
	const publicClient = await readPublicClient(chain);

	return await publicClient.getChainId();
};

const readJson = async (chain: Chain) => {
	const chainId: ChainIdInJson = await readChainId(chain);

	return getJson(chainId);
};

const readLastPrice = async (chain: Chain): Promise<bigint> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);

	return await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'lastPrice'
	});
};

const readBzzBalance = async (chain: Chain, address: Address): Promise<bigint | undefined> => {
	if (address === undefined) return;
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);

	return await publicClient.readContract({
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'balanceOf',
		args: [address]
	});
};

const readNftOwner = async (chain: Chain): Promise<Address> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	const tokenId = await readLastTokenId(chain);

	return await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'ownerOf',
		args: [tokenId]
	});
};

const readNftMetadata = async (chain: Chain): Promise<NftMetadata> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	const tokenId = await readLastTokenId(chain);

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

const readAccount = async (chain: Chain): Promise<Address> => {
	const publicClient = await readPublicClient(chain);

	const chainId = await readChainId(chain);
	const json = await readJson(chain);
	const tokenId = await readLastTokenId(chain);

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

const readBatchLegacy = async (chain: Chain): Promise<[Address, number, bigint]> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	if (!('batchId' in json)) utilsError(`No batchId in json ${String(await readChainId(chain))})`);

	const [owner, depth, , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbiBatcheslegacy,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readBatchNew = async (chain: Chain): Promise<[Address, number, bigint]> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	if (!('batchId' in json)) utilsError(`No batchId in json ${String(await readChainId(chain))})`);

	const [owner, depth, , , rBal] = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'batches',
		args: [json.batchId as Hex]
	});

	return [owner, depth, rBal];
};

const readLastTokenId = async (chain: Chain): Promise<bigint> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	if (!('batchId' in json))  utilsError(`No batchId in json ${String(await readChainId(chain))})`);

	const data = await publicClient.readContract({
		address: json.NFTCollection as Address,
		abi: erc721Abi,
		functionName: 'totalSupply'
	});

	return data;
};

const readRemainingBalance = async (chain: Chain): Promise<bigint> => {
	const publicClient = await readPublicClient(chain);

	const json = await readJson(chain);
	if (!('batchId' in json)) utilsError(`No batchId in json ${String(await readChainId(chain))})`);

	const data = await publicClient.readContract({
		address: json.PostageStamp as Address,
		abi: postageStampAbi,
		functionName: 'remainingBalance',
		args: [json.batchId as Hex]
	});

	return data;
};

export {
	readPublicClient,
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
	readRemainingBalance,
	readBlock
};
