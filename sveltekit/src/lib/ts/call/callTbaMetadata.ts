import { callTbaBzzHash, callTbaBzzSize, callTbaBzzStampId } from './callTba';
import type { Metadata, NftMetadata, BzzMetadata, TbaMetadata } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchUrl } from '../fetch/fetch';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { bzzImageName } from '../swarm/bzz';
import { utilsDivUp, utilsIsBytes32Null } from '../common/utils';
import { callIsContract } from './call';
import { callBzzBalance } from './callBzz';
import { STAMP_SIZE, STAMP_PRICE } from '../constants/constants';
import type { Address } from 'viem';
import { nftIds } from '../common/nft';

const _callTbaMetadata = async (
	tbaChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<TbaMetadata> => {
	// console.info('_callTbaMetadata  IN\n', metadata);

	const tbaMetadata: TbaMetadata = {};

	tbaMetadata.tbaChainId = tbaChainId;
	tbaMetadata.tbaAddress = await callRegistryAccount(
		tbaChainId,
		nftChainId,
		nftCollection,
		nftTokenId
	);
	tbaMetadata.tbaDeployed = await callIsContract(tbaChainId, tbaMetadata.tbaAddress);
	tbaMetadata.tbaBalance = await callBzzBalance(tbaChainId, tbaMetadata.tbaAddress);

	if (tbaMetadata.tbaDeployed) {
		const tbaHash = await callTbaBzzHash(tbaChainId, tbaMetadata.tbaAddress);
		if (!utilsIsBytes32Null(tbaHash)) {
			tbaMetadata.tbaHash ||= tbaHash;
			tbaMetadata.tbaSize ||= await callTbaBzzSize(tbaChainId, tbaMetadata.tbaAddress);
			tbaMetadata.tbaPrice ||= utilsDivUp(tbaMetadata.tbaSize!, STAMP_SIZE) * STAMP_PRICE;

			if (utilsIsBytes32Null(tbaMetadata.tbaStampId))
				tbaMetadata.tbaStampId = await callTbaBzzStampId(tbaChainId, tbaMetadata.tbaAddress);

			const imageName = await bzzImageName(tbaMetadata.tbaHash!);
			if (imageName) {
				tbaMetadata.tbaImageName = imageName;
				tbaMetadata.tbaTokenUriAlt ||= await fetchAltUrl(tbaMetadata.tbaTokenUri);
				tbaMetadata.tbaImageAlt ||= await fetchAltUrl(tbaMetadata.tbaImage);
			}
		}
	}
	return tbaMetadata;
};

const callTbaMetadata = async (
	tbaChainId: number,
	nftMetadata: NftMetadata
): Promise<TbaMetadata> => {
	if (!nftMetadata) throw new Error(`callTbaMetadataFromNft: No Nft AutoSwarm Metadata`);

	const tbaMetadata = await _callTbaMetadata(tbaChainId, ...nftIds(nftMetadata));

	return tbaMetadata;
};

const callTbaMetadataWithoutNft = async (
	tbaChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<[Metadata, TbaMetadata]> => {
	const tbaMetadata = await _callTbaMetadata(tbaChainId, nftChainId, nftCollection, nftTokenId);
	const metadata = (await fetchUrl(tbaMetadata.tbaTokenUriAlt)) as unknown as Metadata;

	return [metadata, tbaMetadata];
};

export { callTbaMetadata, callTbaMetadataWithoutNft };
