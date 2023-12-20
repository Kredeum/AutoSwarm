import type { Address, Hex } from 'viem';

type NftMetadata = {
	nftChainId: number;
	nftCollection: Address;
	nftTokenId: bigint;
	nftMetadataUri?: string;
	nftMetadataUriAlt?: string;
	nftMetadataSize?: number;
	nftImageUri?: string;
	nftImageUriAlt?: string;
	nftImageSize?: number;
};

type BzzMetadata = {
	bzzSize?: bigint;
	bzzPrice?: bigint;
	bzzHash?: Hex;
	bzzImageName?: string;
};

type TbaMetadata = {
	tbaChainId?: number;
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

type Metadata = {
	name: string;
	description: string;
	image: string;
	image_url?: string;
	autoSwarmNft?: NftMetadata;
	autoSwarmBzz?: BzzMetadata;
	autoSwarmTba?: TbaMetadata;
	[key: string]: unknown;
};
type AddressesType = Record<string, string>;

export type { Metadata, NftMetadata, BzzMetadata, TbaMetadata, AddressesType };
