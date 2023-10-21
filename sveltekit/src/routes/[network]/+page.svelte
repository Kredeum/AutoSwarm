<script lang="ts">
	import { onMount } from 'svelte';
	import type { Address } from 'viem';

	import {
		type NftMetadata,
		ONE_YEAR,
		SECONDS_PER_BLOCK,
		AUTOSWARM_UNIT_PRICE
	} from '$lib/ts/constants.js';
	import { writeWalletAddress } from '$lib/ts/write';
	import { writeStampsTopUp } from '$lib/ts/writeStamps.js';
	import {
		readAccount,
		readBatchLegacy,
		readBzzBalance,
		readLastPrice,
		readNftMetadata,
		readRemainingBalance
	} from '$lib/ts/read.js';
	import { getBatchId } from '$lib/ts/get';
	import { displayBalance, displayDuration, displayTxt } from '$lib/ts/display';

	export let data;
	const { chain } = data;

	let nftMetadataJson: NftMetadata;

	let batchId = getBatchId(100);
	let autoSwarmAddress: Address;
	let autoSwarmBalance: bigint;
	let remainingBalance: bigint;
	let lastPrice = 0n;
	let duration: bigint;
	let topping = false;
	let walletAddress: Address;
	let walletBalance: bigint;

	const refreshDisplay = async () => {
    console.log("refreshDisplay");
    
		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance(chain, walletAddress);

		autoSwarmAddress = await readAccount(chain);
		autoSwarmBalance = await readBzzBalance(chain, autoSwarmAddress);

		remainingBalance = await readRemainingBalance(chain);
		lastPrice = await readLastPrice(chain);
		await readBatchLegacy(chain);

		if (lastPrice > 0) duration = (remainingBalance * BigInt(SECONDS_PER_BLOCK)) / lastPrice;
	};

	const topUp = async () => {
		if (topping) return;
		console.info('topUp');

		await writeStampsTopUp(chain, (BigInt(ONE_YEAR) * lastPrice) / BigInt(SECONDS_PER_BLOCK));

		topping = false;
		refreshDisplay();
	};

	onMount(async () => {
		nftMetadataJson = await readNftMetadata(chain);
		refreshDisplay();
	});
</script>

<section>
	{#if nftMetadataJson}
		<div class="nfts-grid">
			<article>
				<div
					title="NFT Collection Address  @{nftMetadataJson.address}"
					class="nft-img"
					style="background-image: url({nftMetadataJson.image});"
					aria-label={nftMetadataJson.description}
				/>
				<p class="nft-title">{nftMetadataJson.name} <span># {nftMetadataJson.tokenId}</span></p>
			</article>
		</div>
		<section class="user-config">
			<p class="intro-text">NFT selected, click on TopUp to increase NFT lifespan on Swarm</p>
			Chain {data.chain.name}
			<!-- <p>
      <a class="details-link" href="gnosis/details">gnosis</a> -
			<a class="details-link" href="sepolia/details">sepolia</a> -
			<a class="details-link" href="anvil/details">anvil</a>
		</p> -->
		</section>
		<div class="batch-topUp">
			<div class="batch-topUp-infos">
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
				<p>Price: {displayBalance(AUTOSWARM_UNIT_PRICE, 16)} Bzz / Mo</p>
				<p>
					{walletAddress}
					<!-- {#if walletBalance}Your Balance: {displayBalance(walletBalance, 16)} Bzz{/if} -->
				</p>
			</div>
		</div>
	{/if}
</section>
