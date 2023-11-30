import type { Address, Hex } from 'viem';

type NftMetadataAutoSwarm = {
	nftTokenUri?: string;
	nftTokenUriAlt?: string;
	nftImage?: string;
	nftImageAlt?: string;
	bzzChainId?: number;
	bzzHash?: Hex;
	tbaAddress?: Address;
	tbaTokenUri?: string;
	tbaImage?: string;
};

type NftMetadataErc721 = {
	image: string;
	name: string;
	description: string;
};

type NftMetadata = NftMetadataErc721 & {
	autoSwarm?: NftMetadataAutoSwarm;
	[key: string]: unknown;
};

export type { NftMetadataErc721, NftMetadata, NftMetadataAutoSwarm };
