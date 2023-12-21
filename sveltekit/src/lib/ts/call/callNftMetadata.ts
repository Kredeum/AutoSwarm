import type { Address } from 'viem';
import type { NftMetadata, Metadata } from '$lib/ts/constants/types';
import { fetchJson } from '../fetch/fetchJson';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { fetchSize } from '../fetch/fetchSize';

import { callNftTokenUri } from './callNft';
import { STAMP_PRICE, STAMP_SIZE } from '../constants/constants';
import { fetchNftTar } from '../fetchBee/fetchNftTar';
import { utilsDivUp } from '../common/utils';

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callNftMetadata = async (
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<[Metadata, NftMetadata]> => {
	// console.info('callNftMetadata  IN', nftChainId, nftCollection, nftTokenId);

	const nftMetadataUri = await callNftTokenUri(nftChainId, nftCollection, nftTokenId);
	if (!nftMetadataUri) throw new Error(`callNftMetadata: No Token Uri`);

	const nftMetadataUriAlt = await fetchAltUrl(nftMetadataUri);
	if (!nftMetadataUriAlt) throw new Error(`callNftMetadata: Broken Token Uri ${nftMetadataUri}`);

	const metadata = (await fetchJson(nftMetadataUriAlt)) as Metadata;
	if (!metadata) throw new Error(`callNftMetadata: No Metadata for Token Uri ${nftMetadataUri}`);
	const nftMetadataSize = nftMetadataUriAlt.length;

	const nftImageUri = metadata.image || metadata.image_url;
	const nftImageUriAlt = await fetchAltUrl(nftImageUri);
	const nftImageSize = await fetchSize(nftImageUriAlt);

	const [body, nftImageName] = await fetchNftTar([nftImageUri, nftMetadataUri]);
	console.log('body.length:', body.length);
	const nftSize = BigInt(body.length);
	const nftPrice = utilsDivUp(nftSize, STAMP_SIZE) * STAMP_PRICE;

	const nftMetadata = {
		nftChainId,
		nftCollection,
		nftTokenId,
		nftMetadataUri,
		nftMetadataUriAlt,
		nftMetadataSize,
		nftImageUri,
		nftImageUriAlt,
		nftImageSize,
		nftImageName,
		nftSize,
		nftPrice
	};
	Object.freeze(metadata);
	Object.freeze(nftMetadata);

	// console.info('callNftMetadata', '\n', metadata);
	// console.info('callNftMetadata', '\n', metadata.nftMetadata);
	return [metadata, nftMetadata];
};

export { callNftMetadata };
