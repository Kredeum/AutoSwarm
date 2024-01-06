<script lang="ts">
	import { callBlockNumber } from '$lib/ts/call/call';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import {
		callMarketCurrentBatchFilling,
		callMarketCurrentBatchId,
		callMarketCurrentNodeOwner
	} from '$lib/ts/call/callMarket';
	import {
		callPostageBatches,
		callPostageCurrentTotalOutPayment,
		callPostageLastPrice,
		callPostageRemainingBalance
	} from '$lib/ts/call/callPostage';
	import { callMarketGetStampsCount } from '$lib/ts/call/callStamps';
	import { addressesGetField } from '$lib/ts/common/addresses';
	import { utilsIsNullBytes32 } from '$lib/ts/common/utils';
	import {
		BATCH_DEPTH,
		BATCH_SIZE,
		BATCH_TTL,
		CHUNK_PRICE_DEFAULT,
		UNDEFINED_ADDRESS,
		UNDEFINED_DATA
	} from '$lib/ts/constants/constants';
	import { displayBalance, displayPerCent, displaySize, displayTtl } from '$lib/ts/display/display';
	import { displayExplorerAddress } from '$lib/ts/display/displayExplorer';
	import { alertError } from '$lib/ts/stores/alertMessage';
	import { batchPrice } from '$lib/ts/swarm/batch';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
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
