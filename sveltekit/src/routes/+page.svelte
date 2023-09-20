<script lang="ts">
	import { getBatchId, getDisplayDuration } from '$lib/ts/get.js';
	import {
		readAccount,
		readBzzBalance,
		readLastPrice,
		readRemainingBalance
	} from '$lib/ts/read.js';
	import { onMount } from 'svelte';
	import { createPublicClient, http, type Address } from 'viem';
	import { gnosis } from 'viem/chains';

	export let data;

	const secondsPerBlock = 5n;
	let autoSwarmAddress: Address = '0x0';
	let autoSwarmBalance: bigint;
	let remainingBalance = 0n;
	let lastPrice = 0n;
	let batchId = getBatchId(100);
	let displayBalance = '*****';
	let displayDuration = '***** weeks';

	let topping = false;
	let tokenId = 1;

	const publicClient = createPublicClient({ chain: gnosis, transport: http() });

	const topUp = async () => {
		if (topping) return;
		console.log('topUp');

		topping = false;
	};

	const refreshDisplay = async () => {
		autoSwarmBalance = await readBzzBalance(publicClient, autoSwarmAddress);

		remainingBalance = await readRemainingBalance(publicClient);

		lastPrice = await readLastPrice(publicClient);

		displayBalance = (Number(autoSwarmBalance || 0) / 1e16).toFixed(4);

		displayDuration =
			lastPrice > 0 ? getDisplayDuration((remainingBalance * secondsPerBlock) / lastPrice) : '';
	};

	onMount(async () => {
		autoSwarmAddress = await readAccount(publicClient);
		refreshDisplay();
	});
</script>

<section>
	<div class="nfts-grid">
		{#if data.nftMetadata}
			<article>
				<div
					class="nft-img"
					style="background-image: url({data.nftMetadata.image});"
					aria-label={data.nftMetadata.description}
				/>
				<p class="nft-title">{data.nftMetadata.name} <span># {tokenId}</span></p>
			</article>
		{/if}
	</div>
	<section class="user-config">
		<p class="intro-text">NFT selected, click on TopUp to increase NFT lifespan on Swarm</p>
		<p>
			<a class="details-link" href="./gnosis">see details</a>
		</p>
	</section>
	<div class="batch-topUp">
		<div class="batch-topUp-infos">
			<p title="NFT AutoSwarm {autoSwarmAddress}">NFT AutoSwarm balance</p>
			<p title="{autoSwarmBalance} bzz">
				{displayBalance} Bzz
			</p>
			<p title="batchId {batchId}">Swarm Storage ends in</p>
			<p title="{remainingBalance} seconds">{displayDuration}</p>
		</div>
		<button class="btn btn-topup" on:click={topUp}>
			TopUp 1 Year
			{#if topping}
				<i class="fa-solid fa-spinner fa-spin-pulse" />
			{/if}
		</button>
	</div>
</section>
