<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';
	import { BATCH_DEPTH, BATCH_TTL } from '@autoswarm/common/src/constants/constants';
	import { addressesGetField } from '@autoswarm/common/src/common/addresses';
	import { callBzzBalance } from '@autoswarm/common/src/call/callBzz';
	import { sendBzzTransfer } from '@autoswarm/common/src/send/sendBzz';
	import { sendMarketSync } from '@autoswarm/common/src/send/sendMarket';
	import { callMarketNewBatchNeeded } from '@autoswarm/common/src/call/callMarket';
	import { bzzChainId } from '@autoswarm/common/src/swarm/bzz';
	import { batchPrice } from '@autoswarm/common/src/swarm/batch';
	import { alertError, alertInfo } from '@autoswarm/common/src/stores/alertMessage';
	import DetailsWallet from '../Details/DetailsWallet.svelte';
	import DetailsMarket from '../Details/DetailsMarket.svelte';
	import DetailsPostage from '../Details/DetailsPostage.svelte';
	import { goto } from '$app/navigation';
	import DetailsCurrentBatch from '../Details/DetailsCurrentBatch.svelte';
	import DetailsLocalStorage from '../Details/DetailsLocalStorage.svelte';

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
			<button class="btn btn-topup" on:click={() => goto('/monitor/stamps')}>
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

	{#key buying}
		<div id="monitor-content">
			<hr />
			<DetailsMarket fields="" />
			<hr />
			<DetailsWallet />
			<DetailsLocalStorage fields="batchId" />
			<hr />
			<DetailsCurrentBatch />
			<hr />
			<DetailsPostage />
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
