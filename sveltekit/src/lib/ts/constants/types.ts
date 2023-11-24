import type { Address, Hex } from 'viem';

type NftMetadataAutoSwarm = {
	nftChainId: number;
	nftCollection: Address;
	nftTokenId: bigint;
	nftTokenUri?: string;
	nftTokenUriAlt?: string;
	nftImage?: string;
	nftImageAlt?: string;
	bzzChainId?: number;
	bzzHash?: Hex;
	tbaAddress?: Address;
	tbaTokenUri?: string;
	tbaTokenUriAlt?: string;
	tbaImage?: string;
	tbaImageAlt?: string;
};

type NftMetadataErc721 = {
	image: URL;
	name: string;
	description: string;
};

type NftMetadata = NftMetadataErc721 & {
	autoswarm?: NftMetadataAutoSwarm;
	[key: string]: unknown;
};

export type { NftMetadataErc721, NftMetadata, NftMetadataAutoSwarm };
