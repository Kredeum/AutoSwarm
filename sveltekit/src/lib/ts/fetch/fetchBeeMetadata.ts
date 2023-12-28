import type { BeeMetadata, NftMetadata } from '../constants/types';
import { fetchNftTar } from '$lib/ts/fetchBee/fetchNftTar';
import { fetchBeeTarPost } from '$lib/ts/fetchBee/fetchBeeTar';

import { beeOk } from '../swarm/bee';
import { utilsBytes32Null } from '../common/utils';
import { bzzImageName } from '../swarm/bzz';

const fetchBeeMetadata = async (nftAutoSwarm: NftMetadata): Promise<BeeMetadata> => {
	if (!(await beeOk())) return {};

	const beeMetadata: BeeMetadata = {};

	const [body] = await fetchNftTar([nftAutoSwarm.nftImageUri, nftAutoSwarm.nftMetadataUri]);

	const beeHash = await fetchBeeTarPost(body);
	if (!utilsBytes32Null(beeHash)) {
		beeMetadata.beeHash = beeHash;
		const imageName = await bzzImageName(beeHash);
		if (imageName) beeMetadata.beeImageName = imageName;
	}

	return beeMetadata;
};

export { fetchBeeMetadata };
