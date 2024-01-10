import { callTbaSwarmHash, callTbaSwarmSize, callTbaBzzStampId } from './callTba';
import type { TbaMetadata } from '../constants/types';
import { callRegistryAccount } from './callRegistry';
import { fetchAltUrl } from '../fetch/fetchAlt';
import { bzzImageName } from '../swarm/bzz';
import { utilsDivUp, utilsIsNullBytes32 } from '../common/utils';
import { callIsContract } from './call';
import { callBzzBalance } from './callBzz';
import { STAMP_SIZE, STAMP_PRICE, ONE_YEAR } from '../constants/constants';
import type { Address } from 'viem';
import { callMarketGetStampRemainingBalance } from './callStamps';
import { callMarketStampToBatchId } from './callMarket';

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
		if (!utilsIsNullBytes32(tbaSwarmHash)) {
			tbaMetadata.tbaSwarmHash ||= tbaSwarmHash;
			tbaMetadata.tbaSwarmSize ||= await callTbaSwarmSize(bzzChainId, tbaMetadata.tbaAddress);
			tbaMetadata.tbaPrice ||= utilsDivUp(tbaMetadata.tbaSwarmSize!, STAMP_SIZE) * STAMP_PRICE;

			const imageName = await bzzImageName(tbaSwarmHash);
			if (imageName) {
				tbaMetadata.tbaImageName = imageName;
				tbaMetadata.tbaTokenUriAlt ||= await fetchAltUrl(tbaMetadata.tbaTokenUri);
				tbaMetadata.tbaImageAlt ||= await fetchAltUrl(tbaMetadata.tbaImage);
			}
		}

		if (tbaMetadata.tbaBalance !== undefined && tbaMetadata.tbaPrice) {
			tbaMetadata.tbaBzzDuration =
				(tbaMetadata.tbaBalance * BigInt(ONE_YEAR)) / tbaMetadata.tbaPrice;
		}

		if (utilsIsNullBytes32(tbaMetadata.tbaStampId)) {
			const tbaStampId = await callTbaBzzStampId(bzzChainId, tbaMetadata.tbaAddress);
			if (!utilsIsNullBytes32(tbaStampId)) tbaMetadata.tbaStampId = tbaStampId;
		}

		if (tbaMetadata.tbaStampId && !utilsIsNullBytes32(tbaMetadata.tbaStampId)) {
			try {
				tbaMetadata.tbaBatchId = await callMarketStampToBatchId(bzzChainId, tbaMetadata.tbaStampId);
				const remainingBalance = await callMarketGetStampRemainingBalance(
					bzzChainId,
					tbaMetadata.tbaStampId!
				);
				tbaMetadata.tbaStampDuration = utilsDivUp(remainingBalance, STAMP_PRICE) * BigInt(ONE_YEAR);
			} catch (e) {
				console.error('remainingBalance:', e);
			}
		}

		if (tbaMetadata.tbaBzzDuration || tbaMetadata.tbaStampDuration) {
			tbaMetadata.tbaDuration =
				(tbaMetadata.tbaBzzDuration || 0n) + (tbaMetadata.tbaStampDuration || 0n);
		}
	}
	return tbaMetadata;
};

export { callTbaMetadata };
