import { callTbaSwarmHash, callTbaSwarmSize, callTbaBzzStampId } from './callTba';
import type { TbaMetadata } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { nftImageName } from '../swarm/bzz';
import { utilsDivUp, utilsBytes32Null } from '../common/utils';
import { callIsContract } from './call';
import { callBzzBalance } from './callBzz';
import { STAMP_SIZE, STAMP_PRICE } from '../constants/constants';
import type { Address } from 'viem';

const callTbaMetadata = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<TbaMetadata> => {
	// console.info('_callTbaMetadata  IN\n', metadata);

	const tbaMetadata: TbaMetadata = {};

	tbaMetadata.bzzChainId = bzzChainId;
	tbaMetadata.tbaAddress = await callRegistryAccount(
		bzzChainId,
		nftChainId,
		nftCollection,
		nftTokenId
	);
	tbaMetadata.tbaDeployed = await callIsContract(bzzChainId, tbaMetadata.tbaAddress);
	tbaMetadata.tbaBalance = await callBzzBalance(bzzChainId, tbaMetadata.tbaAddress);

	if (tbaMetadata.tbaDeployed) {
		const tbaSwarmHash = await callTbaSwarmHash(bzzChainId, tbaMetadata.tbaAddress);
		if (!utilsBytes32Null(tbaSwarmHash)) {
			tbaMetadata.tbaSwarmHash ||= tbaSwarmHash;
			tbaMetadata.tbaSwarmSize ||= await callTbaSwarmSize(bzzChainId, tbaMetadata.tbaAddress);
			tbaMetadata.tbaPrice ||= utilsDivUp(tbaMetadata.tbaSwarmSize!, STAMP_SIZE) * STAMP_PRICE;

			if (utilsBytes32Null(tbaMetadata.tbaStampId))
				tbaMetadata.tbaStampId = await callTbaBzzStampId(bzzChainId, tbaMetadata.tbaAddress);

			const imageName = await nftImageName(tbaMetadata.tbaSwarmHash!);
			if (imageName) {
				tbaMetadata.tbaImageName = imageName;
				tbaMetadata.tbaTokenUriAlt ||= await fetchAltUrl(tbaMetadata.tbaTokenUri);
				tbaMetadata.tbaImageAlt ||= await fetchAltUrl(tbaMetadata.tbaImage);
			}
		}
	}
	return tbaMetadata;
};

export { callTbaMetadata };
