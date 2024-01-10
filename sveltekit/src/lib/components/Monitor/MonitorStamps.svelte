<script lang="ts">
	import type { Hex } from 'viem';
	import { onMount } from 'svelte';

	import { sendMarketAttachStamps, sendMarketSync } from '$lib/ts/send/sendMarket';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { alertError } from '$lib/ts/stores/alertMessage';
	import DetailsStamps from '../Details/DetailsStamps.svelte';
	import { goto } from '$app/navigation';
	import { callMarketGetAllStampIdsToAttach, callMarketGetStamp } from '$lib/ts/call/callStamps';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';
	import { callNftMetadata } from '$lib/ts/call/callNftMetadata';
	import { fetchBeeMetadata } from '$lib/ts/fetch/fetchBeeMetadata';
	import { callTbaToken } from '$lib/ts/call/callTba';

	/////////////////////////////// Monitor Stamps Component ////////////////////////////
	// <MonitorStamps />
	/////////////////////////////////////////////////////////////////////////////////////

	let attaching = 0;
	let stampIdsToAttach: Hex[];
	let attachStampsNeeded: boolean;
	let currentBatchId: Hex;

	const refresh = async () => {
		try {
			currentBatchId = await callMarketCurrentBatchId($bzzChainId);
			stampIdsToAttach = await callMarketGetAllStampIdsToAttach($bzzChainId);
			attachStampsNeeded = stampIdsToAttach.length > 0;
		} catch (e) {
			alertError('<Monitor Stamps Refresh', e);
		}
		console.log('refresh ~ monthlyCroning:', attaching);
	};

	const attachStamps = async () => {
		if (!attachStampsNeeded) return;
		console.info('attachStamps');

		try {
			if (attaching) throw new Error('Daily Cron already running!');

			{
				attaching = 1;
				// console.log(`attach Stamps to batchId ${batchId}`);

				let i = 0;
				for await (const stampId of stampIdsToAttach) {
					console.log(`attach stampId #${i++} = ${stampId}`);

          const stamp = await callMarketGetStamp($bzzChainId, stampId);
					const tbaAddress = stamp.owner;
					const [nftChainId, nftCollection, nftTokenId] = await callTbaToken(
						$bzzChainId,
						tbaAddress
					);
					const [, nftMetadata] = await callNftMetadata(
						Number(nftChainId),
						nftCollection,
						nftTokenId
					);
					const tbaMetadata = await fetchBeeMetadata(nftMetadata);
				}
				await refresh();
			}

			{
				attaching = 2;
				await sendMarketAttachStamps($bzzChainId, stampIdsToAttach, currentBatchId);
				await refresh();
			}
		} catch (e) {
			alertError('<Monitor Stamps:', e);
		}

		attaching = 0;
	};

	onMount(async () => {
		await refresh();
	});
</script>

<div id="monitor">
	<h2>Monitor Stamps</h2>
	<div id="monitor-buttons">
		<p>
			<button class="btn btn-topup" on:click={attachStamps} disabled={!attachStampsNeeded}>
				Attach Stamps
				{#if attaching}
					<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {attaching}/1
				{/if}
			</button>
			<span>
				<button class="btn btn-topup" on:click={() => goto('/monitor/batchs')}>
					Monitor Batchs
				</button>
			</span>
		</p>
	</div>

	{#key attaching}
		<div id="monitor-content">
			<hr />
			<DetailsStamps />
			<hr />
		</div>
	{/key}
</div>

<style>
	#monitor {
		display: flex;
		justify-content: center;
		align-items: center;
		flex-direction: column;
	}

	#monitor-buttons,
	#monitor-content {
		width: 1100px;
		display: block;
		text-align: left;
		justify-content: center;
		align-items: center;
		flex-direction: column;
	}

	#monitor-buttons p span {
		float: right;
	}

	#monitor-content p span {
		float: right;
		font-family: monospace;
	}
</style>
