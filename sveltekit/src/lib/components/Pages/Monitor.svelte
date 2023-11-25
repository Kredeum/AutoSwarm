<script lang="ts">
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { ZERO_BYTES32, BATCH_UNIT_PRICE } from '$lib/ts/constants/constants';
	import { jsonGetField } from '$lib/ts/constants/json';
	import {
		displayBalance,
		displayExplorer,
		displayExplorerAddress,
		displayExplorerField,
		displayExplorerNft,
		displayLink
	} from '$lib/ts/display/display';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendMarketNewBatch } from '$lib/ts/send/sendMarket';
	import { sendWalletAddress } from '$lib/ts/send/send';
	import { utilsError } from '$lib/ts/swarm/utils';
	import type { Address, Hex } from 'viem';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';
	import { callRegistryAccount } from '$lib/ts/call/callRegistry';
	import { onMount } from 'svelte';
	import { callIsContract } from '$lib/ts/call/call';

	import { bzzChainId } from '$lib/ts/swarm/bzz';

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;

	// State
	let monthlyCroning = false;
	let dailyCroning = false;

	const reset = () => {
		currentBatchId = undefined;
	};

	const refresh = async () => {
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance($bzzChainId, walletAddress);

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId($bzzChainId);
		} catch (e) {
			utilsError('<Monitor Refresh', e);
		}
	};

	const dailyCron = async () => {
		console.info('DailyCron');

		try {
			if (dailyCroning) throw Error('Already running!');
			dailyCroning = true;
		} catch (e) {
			utilsError('<Monitor Daily Cron:', e);
		}

		dailyCroning = false;
	};

	const monthlyCron = async () => {
		console.info('MonthlyCron');

		try {
			if (monthlyCroning) throw Error('Already running!');
			monthlyCroning = true;

			const autoSwarmMarket = jsonGetField($bzzChainId, 'AutoSwarmMarket') as Address;
			await sendBzzTransfer($bzzChainId, autoSwarmMarket, BATCH_UNIT_PRICE);
			await sendMarketNewBatch($bzzChainId);
		} catch (e) {
			utilsError('<Monitor Monthly Cron:', e);
		}

		monthlyCroning = false;
	};

	onMount(refresh);
</script>

<div id="monitor">
	<h2>Monitor</h2>

	<div id="monitor-content">
		<p>
			<button class="btn btn-topup" on:click={dailyCron}>
				Daily Cron
				{#if dailyCroning}
					<i class="fa-solid fa-spinner fa-spin-pulse" />
				{/if}
			</button>

			<span>
				<button class="btn btn-topup" on:click={monthlyCron}>
					Monthly Cron
					{#if monthlyCroning}
						<i class="fa-solid fa-spinner fa-spin-pulse" />
					{/if}
				</button>
			</span>
		</p>
		<p>
			currentBatchId <span>{currentBatchId}</span>
		</p>
		<hr />
		<p>
			BZZ Chaind
			<span>{@html displayExplorer($bzzChainId)}</span>
		</p>
		<p>
			BzzToken
			<span>{@html displayExplorerField($bzzChainId, 'BzzToken')}</span>
		</p>
		<p>
			PriceOracle
			<span>{@html displayExplorerField($bzzChainId, 'PriceOracle')}</span>
		</p>
		<p>
			ERC6551Registry
			<span>{@html displayExplorerField($bzzChainId, 'ERC6551Registry')}</span>
		</p>
		<p>
			PostageStamp
			<span>{@html displayExplorerField($bzzChainId, 'PostageStamp')}</span>
		</p>
		<p>
			AutoSwarmAccount
			<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmAccount')}</span>
		</p>
		<p>
			AutoSwarmMarket
			<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmMarket')}</span>
		</p>
	</div>
</div>

<style>
	#monitor {
		display: flex;
		justify-content: center;
		align-items: center;
		flex-direction: column;
	}

	#monitor-content {
		width: 800px;
		display: block;
		text-align: left;
		justify-content: center;
		align-items: center;
		flex-direction: column;
	}
	#monitor-content p span {
		float: right;
	}
</style>
