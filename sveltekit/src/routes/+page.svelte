<script lang="ts">
	import { onMount } from 'svelte';
	import { gnosis } from 'viem/chains';
	import { createPublicClient, http, type Address } from 'viem';

	import { ONE_YEAR, SECONDS_PER_BLOCK, type NftMetadata } from '$lib/ts/constants.js';
	import { getBatchId } from '$lib/ts/get';
	import {
		displayAddress,
		displayBalance,
		displayBzzFromBalance,
		displayDuration,
		displayTxt
	} from '$lib/ts/display';
	import {
		readAccount,
		readBatchLegacy,
		readBzzBalance,
		readLastPrice,
		readNftMetadata,
		readRemainingBalance
	} from '$lib/ts/read.js';
	import { writeTopUp } from '$lib/ts/write.js';
	import { autoSwarmAbi } from '$lib/ts/abis.js';

	let nftMetadataJson: NftMetadata;

	let batchId = getBatchId(100);
	let autoSwarmAddress: Address;
	let autoSwarmBalance: bigint;
	let remainingBalance: bigint;
	let lastPrice = 0n;
	let duration: bigint;
	let oneYearBzz: bigint;
	let depth: number;

	let topping = false;

	const publicClient = createPublicClient({ chain: gnosis, transport: http() });

	const topUp = async () => {
		if (topping) return;
		console.info('topUp');

		await writeTopUp(gnosis, publicClient);

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
     nftMetadataJson = await readNftMetadata(publicClient);

		autoSwarmAddress = await readAccount(publicClient);
		const unwatch = publicClient.watchContractEvent({
			address: autoSwarmAddress,
			abi: autoSwarmAbi,
			onLogs: (logs) => console.log(logs)
		});

		refreshDisplay();
	});
</script>

<section>
	<div class="nfts-grid" >
		{#if nftMetadataJson}
			<article>
				<div title="NFT Collection Address  @{nftMetadataJson.address}"
					class="nft-img"
					style="background-image: url({nftMetadataJson.image});"
					aria-label={nftMetadataJson.description}
				/>
				<p  class="nft-title">{nftMetadataJson.name} <span># {nftMetadataJson.tokenId}</span></p>
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
			<p title="NFT AutoSwarm {displayAddress(autoSwarmAddress)}">NFT AutoSwarm balance</p>
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
