import type { Address, Hex } from 'viem';

type NftMetadataAutoSwarm = {
	nftChainId: number;
	nftCollection: Address;
	nftTokenId: bigint;
	nftTokenUri?: string;
	nftTokenUriSize?: number;
	nftTokenUriAlt?: string;
	nftImage?: string;
	nftImageSize?: number;
	nftImageAlt?: string;
	nftSize?: number;
	bzzChainId?: number;
	bzzHash?: Hex;
	bzzSize?: bigint;
	bzzPrice?: bigint;
	bzzStampId?: Hex;
	tbaAddress?: Address;
	tbaBalance?: bigint;
	tbaDeployed?: boolean;
	tbaTokenUri?: string;
	tbaTokenUriAlt?: string;
	tbaImage?: string;
	tbaImageAlt?: string;
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
