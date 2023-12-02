import type { Address, Hex } from 'viem';

type NftMetadataAutoSwarm = {
	nftTokenUri?: string;
	nftTokenUriAlt?: string;
	nftImage?: string;
	nftImageAlt?: string;
	bzzChainId?: number;
	bzzHash?: Hex;
	bzzSize?: bigint;
	tbaAddress?: Address;
	tbaTokenUri?: string;
	tbaTokenUriSize?: number;
	tbaImage?: string;
	tbaImageSize?: number;
};

type NftMetadataErc721 = {
	name: string;
	description: string;
	image: string;
	image_url?: string;
};

type NftMetadata = NftMetadataErc721 & {
	autoSwarm?: NftMetadataAutoSwarm;
	[key: string]: unknown;
};

export type { NftMetadataErc721, NftMetadata, NftMetadataAutoSwarm };
