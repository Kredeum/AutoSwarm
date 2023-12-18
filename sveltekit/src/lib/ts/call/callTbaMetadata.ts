import { callTbaBzzHash, callTbaBzzSize, callTbaBzzStampId } from './callTba';
import type { NftMetadata, NftMetadataAutoSwarm } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchUrl } from '../fetch/fetch';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { bzzRefs } from '../swarm/bzz';
import { utilsDivUp, utilsIsBytes32Null } from '../common/utils';
import { callIsContract } from './call';
import { callBzzBalance } from './callBzz';
import { STAMP_SIZE, STAMP_PRICE } from '../constants/constants';
import type { Address } from 'viem';
import { nftIds } from '../common/nft';

const _callTbaMetadata = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint,
	nftMetadata?: NftMetadata
): Promise<NftMetadata> => {
	// console.info('_callTbaMetadata  IN\n', nftMetadata);

	const autoSwarm =
		nftMetadata?.autoSwarm || ({ nftChainId, nftCollection, nftTokenId } as NftMetadataAutoSwarm);
	let tbaMetadata = nftMetadata;

	autoSwarm.tbaAddress ||= await callRegistryAccount(
		bzzChainId,
		nftChainId,
		nftCollection,
		nftTokenId
	);
	autoSwarm.bzzChainId ||= bzzChainId;
	autoSwarm.tbaDeployed ||= await callIsContract(bzzChainId, autoSwarm.tbaAddress);
	autoSwarm.tbaBalance = await callBzzBalance(bzzChainId, autoSwarm.tbaAddress);

	if (autoSwarm.tbaDeployed) {
		const tbaHash = await callTbaBzzHash(bzzChainId, autoSwarm.tbaAddress);
		if (!utilsIsBytes32Null(tbaHash)) {
			autoSwarm.tbaHash ||= tbaHash;
			autoSwarm.tbaSize ||= await callTbaBzzSize(bzzChainId, autoSwarm.tbaAddress);
			autoSwarm.tbaPrice ||= utilsDivUp(autoSwarm.tbaSize!, STAMP_SIZE) * STAMP_PRICE;

			if (utilsIsBytes32Null(autoSwarm.tbaStampId))
				autoSwarm.tbaStampId = await callTbaBzzStampId(bzzChainId, autoSwarm.tbaAddress);

			const refs = await bzzRefs(autoSwarm.tbaHash!);
			if (refs) {
				autoSwarm.tbaImageName = refs;
				autoSwarm.tbaTokenUriAlt ||= await fetchAltUrl(autoSwarm.tbaTokenUri);
				autoSwarm.tbaImageAlt ||= await fetchAltUrl(autoSwarm.tbaImage);
			}
			if (!tbaMetadata) {
				tbaMetadata = (await fetchUrl(autoSwarm.tbaTokenUriAlt)) as unknown as NftMetadata;
				tbaMetadata.autoSwarm = autoSwarm;
			}
		}
	}
	if (!tbaMetadata?.autoSwarm) throw new Error(`_callTbaMetadata: No Metadata found!`);

	return tbaMetadata;
};

const callTbaMetadata = async (
	bzzChainId: number,
	nftMetadata: NftMetadata
): Promise<NftMetadata> => {
	if (!nftMetadata?.autoSwarm) throw new Error(`callTbaMetadataFromNft: No Nft AutoSwarm Metadata`);

	const tbaMetadata = await _callTbaMetadata(
		bzzChainId,
		...nftIds(nftMetadata.autoSwarm),
		nftMetadata
	);

	console.info('callTbaMetadata', '\n', Object.assign({}, tbaMetadata.autoSwarm));
	return tbaMetadata;
};

const callTbaMetadataWithoutNft = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<NftMetadata> => {
	return _callTbaMetadata(bzzChainId, nftChainId, nftCollection, nftTokenId);
};

export { callTbaMetadata, callTbaMetadataWithoutNft };
