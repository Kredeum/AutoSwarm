import type { BeeMetadata, NftMetadata } from '../constants/types';
import { fetchNftTar } from '$lib/ts/fetchBee/fetchNftTar';
import { fetchBeeTarPost } from '$lib/ts/fetchBee/fetchBeeTar';

import { beeOk } from '../swarm/bee';

const fetchBeeMetadata = async (nftAutoSwarm: NftMetadata): Promise<BeeMetadata> => {
	if (!(await beeOk())) return {};

	const beeMetadata: BeeMetadata = {};

	const [body] = await fetchNftTar([nftAutoSwarm.nftImageUri, nftAutoSwarm.nftMetadataUri]);

	beeMetadata.beeHash = await fetchBeeTarPost(body);

	return beeMetadata;
};

export { fetchBeeMetadata };
