<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { onMount } from 'svelte';

	import {
		BATCH_DEPTH,
		BATCH_SIZE,
		BATCH_TTL,
		BATCH_PRICE,
		STAMP_SIZE,
		STAMP_TTL,
		STAMP_PRICE
	} from '$lib/ts/constants/constants';
	import { jsonGetField } from '$lib/ts/common/json';
	import { utilsError } from '$lib/ts/common/utils';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import {
		displayBalance,
		displayDuration,
		displayExplorer,
		displayExplorerField,
		displaySize
	} from '$lib/ts/display/display';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendMarketNewBatch } from '$lib/ts/send/sendMarket';
	import { sendWalletAddress } from '$lib/ts/send/send';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import {
		callPostageBatches,
		callPostageBatchesLegacy,
		callPostageRemainingBalance
	} from '$lib/ts/call/callPostage';

	/////////////////////////////// Monitor Component ///////////////////////////////////
	// <Monitor />
	/////////////////////////////////////////////////////////////////////////////////////
	// Daily Cron and Monthly Cron
	/////////////////////////////////////////////////////////////////////////////////////

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;

	let marketBalance: bigint | undefined;

	// Postage
	let currentBatchOwner: Address | undefined;
	let currentBatchTtl: bigint | undefined;
	let currentBatchDepth: number | undefined;
	let currentBatchRemainingBalance: bigint | undefined;
	let currentBatchNormalisedBalance: bigint | undefined;

	// State
	let monthlyCroning = 0;
	let dailyCroning = 0;

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
			marketBalance = await callBzzBalance(
				$bzzChainId,
				jsonGetField($bzzChainId, 'AutoSwarmMarket') as Address
			);

			[currentBatchOwner, currentBatchDepth, currentBatchNormalisedBalance] =
				$bzzChainId == 100
					? await callPostageBatchesLegacy($bzzChainId, currentBatchId)
					: await callPostageBatches($bzzChainId, currentBatchId);

			currentBatchRemainingBalance = await callPostageRemainingBalance($bzzChainId, currentBatchId);
		} catch (e) {
			utilsError('<Monitor Refresh', e);
		}
		console.log('refresh ~ monthlyCroning:', monthlyCroning);
	};

	const dailyCron = async () => {
		console.info('DailyCron');

		try {
			if (dailyCroning) throw Error('Already running!');
			dailyCroning = 1;
		} catch (e) {
			utilsError('<Monitor Daily Cron:', e);
		}

		dailyCroning = 0;
	};

	const monthlyCron = async () => {
		console.info('MonthlyCron');

		try {
			if (monthlyCroning) throw Error('Already running!');

			monthlyCroning = 1;
			console.log('monthlyCron ~ monthlyCroning:', monthlyCroning);
			refresh();

			const autoSwarmMarket = jsonGetField($bzzChainId, 'AutoSwarmMarket') as Address;
			await sendBzzTransfer($bzzChainId, autoSwarmMarket, BATCH_PRICE);

			monthlyCroning = 2;
			refresh();

			await sendMarketNewBatch($bzzChainId);
		} catch (e) {
			utilsError('<Monitor Monthly Cron:', e);
		}
		monthlyCroning = 0;
		refresh();
	};

	onMount(refresh);
</script>

<div id="monitor">
	<h2>Monitor</h2>
	<div id="monitor-buttons">
		<p>
			<button class="btn btn-topup" on:click={dailyCron}>
				Daily Cron
				{#if dailyCroning}
					<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {dailyCroning}/1
				{/if}
			</button>

			<span>
				<button class="btn btn-topup" on:click={monthlyCron}>
					Monthly Cron
					{#if monthlyCroning}
						<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {monthlyCroning}/2
					{/if}
				</button>
			</span>
		</p>
	</div>

	<div id="monitor-content">
		<hr />
		<p>
			All Batchs - Depth / Size / TTL / Price
			<span>
				depth {BATCH_DEPTH} /
				{displaySize(BATCH_SIZE, 2)} /
				{displayDuration(BATCH_TTL)} /
				{displayBalance(BATCH_PRICE, 16, 4)} Bzz
			</span>
		</p>
		<p>
			All Stamps - TTL / Price per Unit
			<span>
				{displayDuration(STAMP_TTL)} /
				{displayBalance(STAMP_PRICE, 16, 3)} Bzz per {displaySize(STAMP_SIZE, 0)}
			</span>
		</p>

		<hr />
		<p>Market - Balance <span>{displayBalance(marketBalance, 16, 4)} Bzz</span></p>
		<p>Market - Current Batch Id <span>{currentBatchId}</span></p>
		<hr />
		<p>Swarm - Current Batch Owner <span>{currentBatchOwner}</span></p>
		<p>Swarm - Current Batch Depth<span>depth {currentBatchDepth}</span></p>
		<p>Swarm - Current Batch NormalisedBalance <span>{currentBatchNormalisedBalance}</span></p>
		<p>Swarm - Current Batch RemainingBalance <span>{currentBatchRemainingBalance}</span></p>
		<p>Swarm - Current Batch TTL <span>{currentBatchTtl}</span></p>
		<hr />
		<p>Bzz Chaind<span>{@html displayExplorer($bzzChainId)}</span></p>
		<p>Bzz Token<span>{@html displayExplorerField($bzzChainId, 'BzzToken')}</span></p>
		<p>ERC6551 Registry<span>{@html displayExplorerField($bzzChainId, 'ERC6551Registry')}</span></p>
		<p>
			AutoSwarmAccount<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmAccount')}</span>
		</p>
		<p>AutoSwarmMarket<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmMarket')}</span></p>
		<p>PostageStamp<span>{@html displayExplorerField($bzzChainId, 'PostageStamp')}</span></p>
		<p>PriceOracle<span>{@html displayExplorerField($bzzChainId, 'PriceOracle')}</span></p>
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
		width: 900px;
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
