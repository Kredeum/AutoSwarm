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
	nftImageName?: string;
	nftSize?: bigint;
	nftPrice?: bigint;
};

type SwarmMetadata = {
	swarmHash?: Hex;
	swarmImageName?: string;
};

type TbaMetadata = {
	bzzChainId?: number;
	tbaSwarmHash?: Hex;
	tbaImageName?: string;
	tbaSwarmSize?: bigint;
	tbaPrice?: bigint;
	tbaStampId?: Hex;
	tbaBatchId?: Hex;
	tbaDuration?: bigint;
	tbaBzzDuration?: bigint;
	tbaStampDuration?: bigint;
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
	[key: string]: unknown;
};
type AddressesType = Record<string, string>;

export type { Metadata, NftMetadata, SwarmMetadata, TbaMetadata, AddressesType };
