import type { Address, Hex } from 'viem';
import { erc1155Abi, erc165Abi, erc721Abi } from '../constants/abis';
import type { NftMetadata } from '$lib/ts/constants/types';
import { callIsContract, callPublicClient } from './call';
import { fetchJson, fetchAltUrl, fetchUrlOk } from '../fetch/fetch';
import { callTbaBzzHash, callTbaTokenUri } from './callTba';
import type { NftMetadataAutoSwarm } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { ZERO_BYTES32 } from '../constants/constants';
import { bzzImageUri, bzzTokenUri } from '../swarm/bzz';

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
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<NftMetadata> => {
	console.log('callNftMetadata', bzzChainId, nftChainId, nftCollection, nftTokenId);

	const nftTokenUri = await callNftTokenUri(nftChainId, nftCollection, nftTokenId);
	const nftTokenUriAlt = await fetchAltUrl(nftTokenUri);
	const nftMetadata = (await fetchJson(nftTokenUriAlt)) as NftMetadata;
	const nftImage = nftMetadata.image;
	const nftImageAlt = await fetchAltUrl(nftImage);
	const nftImageOK = await fetchUrlOk(nftImageAlt);

	const tbaAddress = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
	console.log('tbaAddress:', tbaAddress);

	let bzzHash: Hex | undefined;
	let tbaTokenUri: URL | undefined;
	let tbaTokenUriAlt: URL | undefined;
	let tbaMetadata: NftMetadata | undefined;
	let tbaImageAlt: URL | undefined;
	let tbaImageOK: boolean | undefined;
	const contract = await callIsContract(bzzChainId, tbaAddress);
	if (contract) {
		bzzHash = (await callTbaBzzHash(bzzChainId, tbaAddress)) as Hex;
		console.log('bzzHash:', bzzHash);

		if (bzzHash && bzzHash != ZERO_BYTES32) {
			tbaTokenUri = bzzTokenUri(bzzHash);
			tbaTokenUriAlt = await fetchAltUrl(tbaTokenUri);
			tbaMetadata = (await fetchJson(tbaTokenUriAlt)) as NftMetadata;
			tbaImageAlt = bzzImageUri(bzzHash);
			tbaImageOK = await fetchUrlOk(tbaImageAlt);
		}
	}

	if (!(nftMetadata || tbaMetadata)) throw Error(`NFT metadata lost! ${nftTokenUri}`);
	if (!(nftImageOK || tbaImageOK)) throw Error(`NFT image lost! ${nftMetadata.image}`);

	const metadata = nftMetadata || tbaMetadata;

	const autoswarm: NftMetadataAutoSwarm = {
		nftChainId,
		nftCollection,
		nftTokenId,
		bzzChainId,
		tbaAddress
	};
	if (nftMetadata) {
		autoswarm.nftTokenUri = nftTokenUri?.toString();
		autoswarm.nftTokenUriAlt = nftTokenUriAlt?.toString();
		if (nftImageOK) {
			autoswarm.nftImage = nftImage?.toString();
			autoswarm.nftImageAlt = nftImageAlt?.toString();
		}
	}
	if (bzzHash && bzzHash != ZERO_BYTES32) autoswarm.bzzHash = bzzHash;
	if (tbaMetadata) {
		autoswarm.tbaTokenUri = tbaTokenUri?.toString();
		autoswarm.tbaTokenUriAlt = tbaTokenUriAlt?.toString();
		if (tbaImageOK) {
			autoswarm.tbaImage = tbaMetadata.image?.toString();
			autoswarm.tbaImageAlt = tbaImageAlt?.toString();
		}
	}
	metadata.autoswarm = autoswarm;
	console.log('metadata:', metadata);

	return metadata;
};

const callNftTokenUri = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<URL> => {
	// console.info('callNftTokenUri', nftChainId, nftCollection, nftTokenId);

	const publicClient = await callPublicClient(nftChainId);

	const nftIs1155 = await callNftIs1155(nftChainId, nftCollection);

	let uri: URL;

	if (nftIs1155) {
		uri = new URL(
			await publicClient.readContract({
				address: nftCollection,
				abi: erc1155Abi,
				functionName: 'uri',
				args: [nftTokenId]
			})
		);
	} else {
		uri = new URL(
			await publicClient.readContract({
				address: nftCollection,
				abi: erc721Abi,
				functionName: 'tokenURI',
				args: [nftTokenId]
			})
		);
	}
	// console.info('callNftTokenUri', uri.toString());
	return uri;
};

const callNftIs1155 = async (nftChainId: number, nftCollection: Address): Promise<boolean> => {
	// console.info('callNftIs1155', nftChainId, nftCollection);

	const publicClient = await callPublicClient(nftChainId);

	const data = await publicClient.readContract({
		address: nftCollection,
		abi: erc165Abi,
		functionName: 'supportsInterface',
		args: ['0xd9b67a26']
	});
	// console.info('callNftIs1155', data);

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

export { callNftOwner, callNftTotalSupply, callNftTokenUri, callNftMetadata, callNftIs1155 };
