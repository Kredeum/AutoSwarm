import { callTbaBzzHash, callTbaBzzSize } from './callTba';
import type { NftMetadata, NftMetadataAutoSwarm } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchUrl, fetchUrlOk } from '../fetch/fetch';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { bzz, bzzImage } from '../swarm/bzz';
import { utilsDivUp, utilsIsBytes32Null } from '../common/utils';
import { callIsContract } from './call';
import { callBzzBalance } from './callBzz';
import { STAMP_UNIT, STAMP_UNIT_PRICE } from '../constants/constants';
import type { Address } from 'viem';

const callTbaMetadata = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint,
	nftMetadata?: NftMetadata
): Promise<NftMetadata | undefined> => {
	console.info('callTbaMetadata  IN', bzzChainId, nftMetadata);

	const sameNft =
		nftMetadata &&
		nftMetadata?.autoSwarm &&
		nftMetadata.autoSwarm.nftChainId == nftChainId &&
		nftMetadata.autoSwarm.nftCollection == nftCollection &&
		nftMetadata.autoSwarm.nftTokenId == nftTokenId;

	let tbaMetadata: NftMetadata | undefined;
	let data: NftMetadataAutoSwarm;
	if (sameNft) {
		tbaMetadata = nftMetadata;
		data = nftMetadata.autoSwarm!;
	} else {
		data = { nftChainId, nftCollection, nftTokenId };
	}

	if (!data) throw new Error(`callTbaMetadata: No Nft AutoSwarm Metadata`);

	data.tbaAddress ||= await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
	data.tbaBalance = await callBzzBalance(bzzChainId, data.tbaAddress);
	data.tbaDeployed ||= await callIsContract(bzzChainId, data.tbaAddress);
	data.bzzChainId ||= bzzChainId;

	if (data.tbaDeployed) {
		data.bzzHash ||= await callTbaBzzHash(bzzChainId, data.tbaAddress);
		if (utilsIsBytes32Null(data.bzzHash)) return tbaMetadata;

		data.bzzSize ||= await callTbaBzzSize(bzzChainId, data.tbaAddress);
		data.bzzPrice ||= utilsDivUp(data.bzzSize, STAMP_UNIT) * STAMP_UNIT_PRICE;

		data.tbaTokenUri ||= bzz(data.bzzHash);
		data.tbaTokenUriAlt ||= await fetchAltUrl(data.tbaTokenUri);

		data.tbaImage ||= bzzImage(data.bzzHash);
		data.tbaImageAlt ||= await fetchAltUrl(data.tbaImage);
		if (!sameNft) {
			tbaMetadata = (await fetchUrl(data.tbaTokenUriAlt)) as unknown as NftMetadata;
			tbaMetadata.autoSwarm = data;
		}
	}

	console.info('callTbaMetadata OUT', tbaMetadata);
	return tbaMetadata;
};

export { callTbaMetadata };
