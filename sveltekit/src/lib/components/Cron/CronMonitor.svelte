<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';
	import { BATCH_DEPTH, BATCH_TTL } from '$lib/ts/constants/constants';
	import { addressesGetField } from '$lib/ts/common/addresses';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendMarketSync } from '$lib/ts/send/sendMarket';
	import { callMarketNewBatchNeeded } from '$lib/ts/call/callMarket';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { batchPrice } from '$lib/ts/swarm/batch';
	import { alertError, alertInfo } from '$lib/ts/stores/alertMessage';
	import DetailsAddresses from '../Details/DetailsAddresses.svelte';
	import DetailsWallet from '../Details/DetailsWallet.svelte';
	import DetailsConstants from '../Details/DetailsConstants.svelte';
	import DetailsMarket from '../Details/DetailsMarket.svelte';
	import DetailsPostage from '../Details/DetailsPostage.svelte';

	/////////////////////////////// Monitor Component ///////////////////////////////////
	// <Monitor />
	/////////////////////////////////////////////////////////////////////////////////////
	// Daily Cron and Monthly Cron
	/////////////////////////////////////////////////////////////////////////////////////

	let marketAddress: Address;
	let marketBalance: bigint | undefined;
	let currentBatchPrice: bigint | undefined;
	let newBatchNeeded: boolean | undefined;

	// State
	let monthlyCroning = 0;
	let dailyCroning = 0;

	const refresh = async () => {
		try {
			// AutoSwarmMarket
			marketBalance = await callBzzBalance(
				$bzzChainId,
				addressesGetField($bzzChainId, 'AutoSwarmMarket') as Address
			);
			currentBatchPrice = await batchPrice($bzzChainId, BATCH_DEPTH, BATCH_TTL);
			console.log('refresh1 ~ currentBatchPrice:', currentBatchPrice, $bzzChainId);

			newBatchNeeded = await callMarketNewBatchNeeded($bzzChainId);
			console.log('refresh2 ~ currentBatchPrice:', currentBatchPrice);
		} catch (e) {
			alertError('<Monitor Refresh', e);
		}
		console.log('refresh ~ monthlyCroning:', monthlyCroning);
	};

	const dailyCron = async () => {
		console.info('DailyCron');

		try {
			if (dailyCroning) throw new Error('Daily Cron already running!');
			dailyCroning = 1;
		} catch (e) {
			alertError('<Monitor Daily Cron:', e);
		}

		dailyCroning = 0;
	};

	const monthlyCron = async () => {
		console.info('MonthlyCron');

		try {
			if (monthlyCroning) throw new Error('Already running!');
			if (!currentBatchPrice) throw new Error('No Batch Price');

			{
				monthlyCroning = 1;
				const amount = currentBatchPrice - (marketBalance || 0n);
				if (amount > 0) {
					alertInfo(`Send needed Bzz to AutoSwarm Market`);
					await sendBzzTransfer($bzzChainId, marketAddress, amount);
					refresh();
				}
			}

			{
				monthlyCroning = 2;
				alertInfo(`Confirm Sync`);
				await sendMarketSync($bzzChainId);
				refresh();
			}
		} catch (e) {
			alertError('<Monitor Monthly:', e);
		}

		monthlyCroning = 0;
		refresh();
	};

	onMount(async () => {
		marketAddress = addressesGetField($bzzChainId, 'AutoSwarmMarket') as Address;

		await refresh();
	});
</script>

<div id="monitor">
	<h2>Monitor</h2>
	<div id="monitor-buttons">
		<p>
			<button class="btn btn-topup" on:click={dailyCron}>
				Get Stamps
				{#if dailyCroning}
					<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {dailyCroning}/1
				{/if}
			</button>

			{#if newBatchNeeded}
				<span>
					<button class="btn btn-topup" on:click={monthlyCron}>
						Buy Batch
						{#if monthlyCroning}
							<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {monthlyCroning}/2
						{/if}
					</button>
				</span>
			{/if}
		</p>
	</div>

	<div id="monitor-content">
		<hr />
		<DetailsMarket />
		<hr />
		<DetailsPostage />
		<hr />
		<DetailsConstants />
		<hr />
		<DetailsAddresses />
		<hr />
		<DetailsWallet />
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
