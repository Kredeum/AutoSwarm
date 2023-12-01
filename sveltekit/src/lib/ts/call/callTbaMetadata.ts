import { callTbaBzzHash } from './callTba';
import type { NftMetadata } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchUrlOk } from '../fetch/fetch';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { bzz, bzzImage } from '../swarm/bzz';
import type { Address } from 'viem';
import { callNftMetadata } from './callNftMetadata';
import { utilsIsBytes32Null } from '../common/utils';

const callTbaMetadata = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<NftMetadata | undefined> => {
	// console.info('callTbaMetadata  IN', bzzChainId, nftChainId, nftCollection, nftTokenId);

	const tbaMetadata = await callNftMetadata(nftChainId, nftCollection, nftTokenId);
	if (!tbaMetadata) throw new Error(`callTbaMetadata: No Nft Metadata`);

	tbaMetadata.autoSwarm ||= {};

	const tbaAddress = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
	tbaMetadata.autoSwarm.tbaAddress = tbaAddress;

	const bzzHash = await callTbaBzzHash(bzzChainId, tbaAddress);
	if (utilsIsBytes32Null(bzzHash)) return tbaMetadata;
	tbaMetadata.autoSwarm.bzzHash = bzzHash;

	const tbaTokenUri = bzz(bzzHash);
	tbaMetadata.autoSwarm.tbaTokenUri = tbaTokenUri;

	const tbaImage = bzzImage(bzzHash);
	const tbaImageAlt = await fetchAltUrl(tbaImage);
	const tbaImageOK = await fetchUrlOk(tbaImageAlt);
	if (tbaImageOK) tbaMetadata.autoSwarm.tbaImage = tbaImage;

	console.info('callTbaMetadata OUT', tbaMetadata);
	return tbaMetadata;
};

export { callTbaMetadata };
