import type { Address } from 'viem';
import type { NftMetadataAutoSwarm } from '../constants/types';

const nftIds = (autoSwarm: NftMetadataAutoSwarm | undefined): [number, Address, bigint] => {
	if (!autoSwarm) throw new Error(`No NFT Identification`);

	const nftChainId = autoSwarm.nftChainId;
	const nftCollection = autoSwarm.nftCollection;
	const nftTokenId = autoSwarm.nftTokenId;

	if (!(nftChainId > 0 && nftCollection && nftTokenId >= 0))
		throw new Error(`bad NFT Identification`);

	return [nftChainId, nftCollection, nftTokenId];
};

export { nftIds };
