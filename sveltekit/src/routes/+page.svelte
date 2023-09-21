<script lang="ts">
	import { getBatchId } from '$lib/ts/get';
	import {
		displayBalance,
		displayBzzFromBalance,
		displayDuration,
		displayTxt
	} from '$lib/ts/display';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readLastPrice,
		readRemainingBalance
	} from '$lib/ts/read.js';
	import { onMount } from 'svelte';
	import { createPublicClient, http, type Address } from 'viem';
	import { gnosis } from 'viem/chains';
	import { ONE_YEAR, SECONDS_PER_BLOCK } from '$lib/ts/constants.js';

	export let data;

	let batchId = getBatchId(100);
	let autoSwarmAddress: Address = '0x0';
	let autoSwarmBalance: bigint;
	let remainingBalance: bigint;
	let lastPrice = 0n;
	let duration: bigint;
	let oneYearBzz: bigint;
	let depth: number;

	let topping = false;
	let tokenId = 10;

	const publicClient = createPublicClient({ chain: gnosis, transport: http() });

	const topUp = async () => {
		if (topping) return;
		console.log('topUp');

		topping = false;
		refreshDisplay();
	};

	const refreshDisplay = async () => {
		if (!publicClient) return;

		autoSwarmAddress = await readAccount(publicClient);
		autoSwarmBalance = await readBzzBalance(publicClient, autoSwarmAddress);
		remainingBalance = await readRemainingBalance(publicClient);
		lastPrice = await readLastPrice(publicClient);
		oneYearBzz = (lastPrice * BigInt(ONE_YEAR)) / SECONDS_PER_BLOCK;
		[, depth] = await readBatchLegacy(publicClient);

		const secondsPerBlock = 5n;
		if (lastPrice > 0) duration = (remainingBalance * secondsPerBlock) / lastPrice;
	};

	onMount(async () => {
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
				{displayBalance(autoSwarmBalance, 16)} Bzz
			</p>
			<p title="batchId {batchId}">Swarm Storage ends in</p>
			<p title="{displayTxt(remainingBalance)} seconds">{displayDuration(duration)}</p>
		</div>
		<button class="btn btn-topup" on:click={topUp}>
			TopUp 1 Year
			{#if topping}
				<i class="fa-solid fa-spinner fa-spin-pulse" />
			{/if}
		</button>
		<div class="batch-topUp-below">
			<p>
				Price: {displayBzzFromBalance(oneYearBzz, depth)} Bzz
			</p>
		</div>
	</div>
</section>
