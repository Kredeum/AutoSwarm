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
	import { goto } from '$app/navigation';
	import DetailsBatchs from '../Details/DetailsBatchs.svelte';

	/////////////////////////////// Monitor Component ///////////////////////////////////
	// <MonitorBuyBatch />
	/////////////////////////////////////////////////////////////////////////////////////
	// Buy Batch
	/////////////////////////////////////////////////////////////////////////////////////

	let marketAddress: Address;
	let marketBalance: bigint | undefined;
	let currentBatchPrice: bigint | undefined;
	let newBatchNeeded: boolean | undefined;

	// State
	let buying = 0;

	const refresh = async () => {
		try {
			marketBalance = await callBzzBalance($bzzChainId, marketAddress);
			currentBatchPrice = await batchPrice($bzzChainId, BATCH_DEPTH, BATCH_TTL);
			newBatchNeeded = await callMarketNewBatchNeeded($bzzChainId);
		} catch (e) {
			alertError('<Monitor Refresh', e);
		}
		console.log('refresh ~ buying:', buying);
	};

	const buyBatch = async () => {
		console.info('buyBatch');

		try {
			if (buying) throw new Error('Already running!');
			if (!currentBatchPrice) throw new Error('No Batch Price');

			{
				buying = 1;
				const amount = currentBatchPrice - (marketBalance || 0n);
				if (amount > 0) {
					alertInfo(`Send needed Bzz to AutoSwarm Market`);
					await sendBzzTransfer($bzzChainId, marketAddress, amount);
					await refresh();
				}
			}

			{
				buying = 2;
				alertInfo(`Confirm Sync`);
				await sendMarketSync($bzzChainId);
				await refresh();
			}
		} catch (e) {
			alertError('<Monitor Monthly:', e);
		}

		buying = 0;
	};

	onMount(async () => {
		marketAddress = addressesGetField($bzzChainId, 'AutoSwarmMarket');

		await refresh();
	});
</script>

<div id="monitor">
	<h2>Monitor - Buy Batch</h2>
	<div id="monitor-buttons">
		<p>
			<button class="btn btn-topup" on:click={() => goto('./monitor-stamps')}>
				Monitor Stamps
			</button>

			<span>
				<button class="btn btn-topup" on:click={buyBatch} disabled={!newBatchNeeded}>
					Buy Batch
					{#if buying}
						<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {buying}/2
					{/if}
				</button>
			</span>
		</p>
	</div>

	<div id="monitor-content">
		<hr />
		<DetailsBatchs />
    <hr />
		<DetailsWallet />
		<hr />
		<DetailsPostage />
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
