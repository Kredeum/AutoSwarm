<script lang="ts">
	import type { Hex } from 'viem';
	import { onMount } from 'svelte';

	import { addressesGetField } from '$lib/ts/common/addresses';

	import { sendMarketAttachStamps, sendMarketSync } from '$lib/ts/send/sendMarket';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { alertError, alertInfo } from '$lib/ts/stores/alertMessage';
	import DetailsStamps from '../Details/DetailsStamps.svelte';
	import { goto } from '$app/navigation';
	import { callMarketGetAllStampsIdsToAttach } from '$lib/ts/call/callStamps';

	/////////////////////////////// Monitor Stamps Component ////////////////////////////
	// <MonitorStamps />
	/////////////////////////////////////////////////////////////////////////////////////

	let attaching = 0;
	let stampIdsToAttach: Hex[] = [];
	let attachStampsNeeded: boolean | undefined;

	const refresh = async () => {
		try {
			stampIdsToAttach = await callMarketGetAllStampsIdsToAttach($bzzChainId);
			attachStampsNeeded = stampIdsToAttach.length > 0;
		} catch (e) {
			alertError('<Monitor Stamps Refresh', e);
		}
		console.log('refresh ~ monthlyCroning:', attaching);
	};

	const attachStamps = async () => {
		console.info('attachStamps');

		try {
			if (attaching) throw new Error('Daily Cron already running!');

			{
				attaching = 1;
				await sendMarketAttachStamps($bzzChainId, stampIdsToAttach);
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
				<button class="btn btn-topup" on:click={() => goto('./monitor-batchs')}>
					Monitor Batchs
				</button>
			</span>
		</p>
	</div>

	<div id="monitor-content">
		<hr />
		{#key attaching}
			<DetailsStamps />
		{/key}
		<hr />
	</div>
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
