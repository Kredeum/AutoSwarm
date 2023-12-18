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
	nftSizeEstimation?: number;
	nftPriceEstimation?: bigint;
	bzzChainId?: number;
	bzzHash?: Hex;
	bzzImageName?: string;
	bzzSize?: bigint;
	bzzPrice?: bigint;
	tbaHash?: Hex;
	tbaImageName?: string;
	tbaSize?: bigint;
	tbaPrice?: bigint;
	tbaStampId?: Hex;
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
type AddressesType = Record<string, string>;

export type { NftMetadataErc721, NftMetadata, NftMetadataAutoSwarm, AddressesType };
