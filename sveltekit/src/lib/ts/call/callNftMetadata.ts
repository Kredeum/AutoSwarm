import type { Address } from 'viem';
import type { NftMetadata } from '$lib/ts/constants/types';
import { fetchJson } from '../fetch/fetchJson';
import { fetchAltUrl } from '../fetch/fetchAlt';
import type { NftMetadataAutoSwarm } from '../constants/types';

import { callNftTokenUri } from './callNft';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callNftMetadata = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<NftMetadata> => {
	// console.info('callNftMetadata  IN', nftChainId, nftCollection, nftTokenId);

	const nftTokenUri = await callNftTokenUri(nftChainId, nftCollection, nftTokenId);
	if (!nftTokenUri) throw new Error(`callNftMetadata: No Token Uri`);

	const nftTokenUriAlt = await fetchAltUrl(nftTokenUri);
	if (!nftTokenUriAlt) throw new Error(`callNftMetadata: Broken Token Uri ${nftTokenUri}`);

	const nftMetadata = (await fetchJson(nftTokenUriAlt)) as NftMetadata;
	if (!nftMetadata) throw new Error(`callNftMetadata: No Metadata for Token Uri ${nftTokenUri}`);

	const nftImage = nftMetadata.image || nftMetadata.image_url;
	const nftImageAlt = await fetchAltUrl(nftImage);

	nftMetadata.autoSwarm = {} as NftMetadataAutoSwarm;
	nftMetadata.autoSwarm.nftChainId = nftChainId;
	nftMetadata.autoSwarm.nftCollection = nftCollection;
	nftMetadata.autoSwarm.nftTokenId = nftTokenId;
	nftMetadata.autoSwarm.nftTokenUri = nftTokenUri;
	nftMetadata.autoSwarm.nftTokenUriAlt = nftTokenUriAlt;
	nftMetadata.autoSwarm.nftImage = nftImage;
	nftMetadata.autoSwarm.nftImageAlt = nftImageAlt;

	console.info('callNftMetadata', '\n', nftMetadata.autoSwarm, '\n', nftMetadata);
	return nftMetadata;
};

export { callNftMetadata };
