<script lang="ts">
	import { callBlockNumber } from '@autoswarm/common/src/call/call';
	import { callBzzBalance } from '@autoswarm/common/src/call/callBzz';
	import {
		callMarketCurrentBatchFilling,
		callMarketCurrentBatchId,
		callMarketCurrentNodeOwner
	} from '@autoswarm/common/src/call/callMarket';
	import {
		callPostageBatches,
		callPostageCurrentTotalOutPayment,
		callPostageLastPrice,
		callPostageRemainingBalance
	} from '@autoswarm/common/src/call/callPostage';
	import { callMarketGetStampsCount } from '@autoswarm/common/src/call/callStamps';
	import { addressesGetField } from '@autoswarm/common/src/common/addresses';
	import { utilsIsNullBytes32 } from '@autoswarm/common/src/common/utils';
	import {
		BATCH_DEPTH,
		BATCH_SIZE,
		BATCH_TTL,
		CHUNK_PRICE_DEFAULT,
		UNDEFINED_ADDRESS,
		UNDEFINED_DATA
	} from '@autoswarm/common/src/constants/constants';
	import {
		displayBalance,
		displayPerCent,
		displaySize,
		displayTtl
	} from '@autoswarm/common/src/display/display';
	import { displayExplorerAddress } from '@autoswarm/common/src/display/displayExplorer';
	import { alertError } from '@autoswarm/common/src/stores/alertMessage';
	import { batchPrice } from '@autoswarm/common/src/swarm/batch';
	import { bzzChainId } from '@autoswarm/common/src/swarm/bzz';
	import { onMount } from 'svelte';
	import type { Address, Hex } from 'viem';
	import DetailsMarket from './DetailsMarket.svelte';
	import DetailsAddress from './DetailsAddress.svelte';

	///////////////////////////// Details Market ///////////////////////////////////////
	// <DetailsMarket />
	/////////////////////////////////////////////////////////////////////////////////////
	let lastBlockNumber: bigint | undefined;
	let marketAddress: Address | undefined;
	let marketBalance: bigint | undefined;

	let chunckPrice: bigint | undefined;
	let currentBatchId: Hex | undefined;
	let currentNodeOwner: Address | undefined;
	let currentBatchOwner: Address | undefined;
	let currentBatchDepth: number | undefined;
	let currentBatchBucketDepth: number | undefined;
	let currentBatchImmutableFlag: boolean | undefined;
	let currentBatchNormalisedBalance: bigint | undefined;
	let currentBatchLastUpdatedBlockNumber: bigint | undefined;

	let stampsCount: number | undefined;
	let currentBatchRemainingBalance: bigint | undefined;
	let currentBatchFilling: bigint | undefined;

	const refresh = async () => {
		try {
			lastBlockNumber = await callBlockNumber($bzzChainId);
			stampsCount = await callMarketGetStampsCount($bzzChainId);
			marketBalance = await callBzzBalance(
				$bzzChainId,
				addressesGetField($bzzChainId, 'AutoSwarmMarket')
			);

			chunckPrice = (await callPostageLastPrice($bzzChainId)) || CHUNK_PRICE_DEFAULT;

			currentNodeOwner = await callMarketCurrentNodeOwner($bzzChainId);
			currentBatchId = await callMarketCurrentBatchId($bzzChainId);
			currentBatchFilling = await callMarketCurrentBatchFilling($bzzChainId);

			if (!utilsIsNullBytes32(currentBatchId)) {
				[
					currentBatchOwner,
					currentBatchDepth,
					currentBatchBucketDepth,
					currentBatchImmutableFlag,
					currentBatchNormalisedBalance,
					currentBatchLastUpdatedBlockNumber
				] = await callPostageBatches($bzzChainId, currentBatchId);

				currentBatchRemainingBalance = await callPostageRemainingBalance(
					$bzzChainId,
					currentBatchId
				);
			}
		} catch (e) {
			alertError('<DetailsBatchs Refresh', e);
		}
	};

	onMount(async () => {
		marketAddress = addressesGetField($bzzChainId, 'AutoSwarmMarket');

		await refresh();
	});
</script>

<p>Market | Batch Id <span>{currentBatchId || UNDEFINED_DATA}</span></p>

<DetailsAddress address={currentBatchOwner} label="Market | Batch Owner" />

<hr />

<p>
	Market | Batch Immutable? / Bucket Depth / Depth / TTL
	<span>
		{currentBatchImmutableFlag ? 'immutable' : 'mutable'} / 2<sup
			>{currentBatchBucketDepth || UNDEFINED_DATA}</sup
		>
		/ 2<sup>{currentBatchDepth || UNDEFINED_DATA}</sup> /
		{displayTtl(currentBatchRemainingBalance, chunckPrice)}
	</span>
</p>

<p>
	Market | Batch Block - Last Updated Block = Delta
	<span>
		#{lastBlockNumber || UNDEFINED_DATA}
		- #{currentBatchLastUpdatedBlockNumber || UNDEFINED_DATA}
		= &#916;{lastBlockNumber && currentBatchLastUpdatedBlockNumber
			? lastBlockNumber - currentBatchLastUpdatedBlockNumber
			: UNDEFINED_DATA}
	</span>
</p>
<p>
	Market | Batch Size / Filling / Filling % / Stamps Count
	<span>
		{displaySize(BATCH_SIZE)} /
		{displaySize(currentBatchFilling)} /
		{displayPerCent(currentBatchFilling, BATCH_SIZE)} /
		{stampsCount}
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
