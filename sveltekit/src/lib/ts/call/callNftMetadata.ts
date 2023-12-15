import type { Address } from 'viem';
import type { NftMetadata } from '$lib/ts/constants/types';
import { fetchJson } from '../fetch/fetchJson';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { fetchSize } from '../fetch/fetch';

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
	const nftTokenUriSize = nftTokenUriAlt.length;

	const nftImage = nftMetadata.image || nftMetadata.image_url;
	const nftImageAlt = await fetchAltUrl(nftImage);
	const nftImageSize = await fetchSize(nftImageAlt);

	// nftSize estimated 10% larger than sum of both sizes
	const nftSize = Math.ceil(((nftTokenUriSize + (nftImageSize || 0)) * 11) / 10);

	nftMetadata.autoSwarm = {
		nftChainId,
		nftCollection,
		nftTokenId,
		nftSize,
		nftTokenUri,
		nftTokenUriAlt,
		nftTokenUriSize,
		nftImage,
		nftImageAlt,
		nftImageSize
	};
	Object.freeze(nftMetadata);

	console.info('callNftMetadata', '\n', Object.assign({}, nftMetadata.autoSwarm));
	// console.info('callNftMetadata', '\n', nftMetadata);
	return nftMetadata;
};

export { callNftMetadata };
