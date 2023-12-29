<script lang="ts">
	import { callBlockNumber } from '$lib/ts/call/call';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import {
		callMarketCurrentBatchFilling,
		callMarketCurrentBatchId,
		callMarketCurrentSwarmNode,

	} from '$lib/ts/call/callMarket';
	import {
		callPostageBatches,
		callPostageCurrentTotalOutPayment,
		callPostageLastPrice,
		callPostageRemainingBalance
	} from '$lib/ts/call/callPostage';
	import { callMarketGetAllStampsIds, callMarketGetAllStampsIdsToAttach, callMarketGetStampsCount } from '$lib/ts/call/callStamps';
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

	///////////////////////////// Details Market ///////////////////////////////////////
	// <DetailsMarket />
	/////////////////////////////////////////////////////////////////////////////////////
	let lastBlockNumber: bigint | undefined;
	let marketAddress: Address | undefined;
	let marketBalance: bigint | undefined;

	let chunckPrice: bigint | undefined;
	let currentBatchId: Hex | undefined;
	let currentSwarmNode: Address | undefined;
	let currentBatchOwner: Address | undefined;
	let currentBatchDepth: number | undefined;
	let currentBatchBucketDepth: number | undefined;
	let currentBatchImmutableFlag: boolean | undefined;
	let currentBatchNormalisedBalance: bigint | undefined;
	let currentBatchLastUpdatedBlockNumber: bigint | undefined;

	let stampsCountToAttach: number | undefined;
	let stampsCount: number | undefined;
	let currentBatchRemainingBalance: bigint | undefined;
	let currentBatchFilling: bigint | undefined;
	let stampsIdsToAttach: readonly Hex[] | undefined;
	let stampsIds: readonly Hex[] | undefined;

	const refresh = async () => {
		try {
			lastBlockNumber = await callBlockNumber($bzzChainId);

			stampsCount = await callMarketGetStampsCount($bzzChainId);
			stampsIds = await callMarketGetAllStampsIds($bzzChainId );
			if (stampsCount !== stampsIds.length)
				throw new Error(`Bad stamp count ${stampsCount} !== ${stampsIds.length}`);

			stampsIdsToAttach = await callMarketGetAllStampsIdsToAttach($bzzChainId, 2);
			stampsCountToAttach = stampsIdsToAttach.length;

			marketBalance = await callBzzBalance(
				$bzzChainId,
				addressesGetField($bzzChainId, 'AutoSwarmMarket')
			);

			chunckPrice = (await callPostageLastPrice($bzzChainId)) || CHUNK_PRICE_DEFAULT;

			currentSwarmNode = await callMarketCurrentSwarmNode($bzzChainId);
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
			alertError('<DetailsStamps refresh', e);
		}
	};

	onMount(async () => {
		marketAddress = addressesGetField($bzzChainId, 'AutoSwarmMarket');

		await refresh();
	});
</script>

<p>
	Market | Stamps To Attach / Total
	<span>
		{stampsCountToAttach} /
		{stampsCount}
	</span>
</p>
<hr />
{#each stampsIdsToAttach || [] as stampId, index}
	<p>
		Market | Stamp#{index} To Attach - StampId
		<span>
			{stampId}
		</span>
	</p>
{/each}
<hr />
{#each stampsIds || [] as stampId, index}
	<p>
		Market | StampId #{index}
		<span>
			{stampId}
		</span>
	</p>
{/each}

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
