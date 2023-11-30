import { callTbaBzzHash } from './callTba';
import type { NftMetadata } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchAltUrl, fetchUrlOk } from '../fetch/fetch';
import { bzz, bzzImage } from '../swarm/bzz';
import { ZERO_BYTES32 } from '../constants/constants';
import type { Address } from 'viem';
import { callNftMetadata } from './callNftMetadata';

const callTbaMetadata = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<NftMetadata | undefined> => {
	const tbaMetadata = await callNftMetadata(nftChainId, nftCollection, nftTokenId);
	if (!tbaMetadata) throw new Error(`callTbaMetadata: No Nft Metadata`);

	tbaMetadata.autoSwarm ||= {};

	const tbaAddress = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
	tbaMetadata.autoSwarm.tbaAddress = tbaAddress;

	const bzzHash = await callTbaBzzHash(bzzChainId, tbaAddress);
	if (!(bzzHash && bzzHash !== ZERO_BYTES32)) return tbaMetadata;
	tbaMetadata.autoSwarm.bzzHash = bzzHash;

	const tbaTokenUri = bzz(bzzHash);
	tbaMetadata.autoSwarm.tbaTokenUri = tbaTokenUri;

	const tbaImage = bzzImage(bzzHash);
	const tbaImageAlt = await fetchAltUrl(tbaImage);
	const tbaImageOK = await fetchUrlOk(tbaImageAlt);
	if (tbaImageOK) tbaMetadata.autoSwarm.tbaImage = tbaImage;

	console.info('tbaMetadata:', tbaMetadata);
	return tbaMetadata;
};

export { callTbaMetadata };
