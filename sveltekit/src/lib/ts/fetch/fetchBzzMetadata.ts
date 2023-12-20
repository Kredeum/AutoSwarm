import type { BzzMetadata, NftMetadata } from '../constants/types';
import { fetchBzzTar, fetchBzzTarPost } from '../fetchBzz/fetchBzzTar';

import { STAMP_PRICE, STAMP_SIZE } from '../constants/constants';
import { utilsDivUp } from '../common/utils';
import { beeOk } from '../swarm/bee';

const fetchBzzMetadata = async (nftAutoSwarm: NftMetadata, post = false): Promise<BzzMetadata> => {
	if (!nftAutoSwarm) throw new Error(`fetchBzzMetadata: No Nft AutoSwarm Metadata`);

	const bzzMetadata: BzzMetadata = {};

	let body: Uint8Array;
	[body, bzzMetadata.bzzImageName] = await fetchBzzTar([
		nftAutoSwarm.nftImageUri,
		nftAutoSwarm.nftMetadataUri
	]);
	bzzMetadata.bzzSize = BigInt(body.length);
	bzzMetadata.bzzPrice = utilsDivUp(bzzMetadata.bzzSize, STAMP_SIZE) * STAMP_PRICE;

	if (post && (await beeOk())) bzzMetadata.bzzHash = await fetchBzzTarPost(body);

	return bzzMetadata;
};

export { fetchBzzMetadata };
