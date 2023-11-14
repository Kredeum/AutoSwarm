<script lang="ts">
	import { zeroAddress, type Address } from 'viem';
	import { onMount, getContext } from 'svelte';
	import { page } from '$app/stores';

	import {
		type NftMetadata,
		ONE_YEAR,
		AUTOSWARM_UNIT_PRICE,
		DEFAULT_PRICE
	} from '$lib/ts/constants/constants.js';
	import { writeTransferBzz, writeWalletAddress } from '$lib/ts/onchain/write';
	import { readBlock, readBzzBalance, readLastPrice } from '$lib/ts/onchain/read.js';
	import { displayBalance, displayDate, displayDuration, displayTxt } from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils.js';
	import { readNftMetadata, readNftTBAccount } from '$lib/ts/onchain/readNft.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	// NFT reference
	const nftChainId = Number($page.params.chainId);
	const collection = $page.params.collection as Address;
	const tokenId = BigInt($page.params.tokenId);

	let blockTimestamp: number | undefined;

	let nftMetadataJson: NftMetadata;

	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	let autoSwarmAddress: Address | undefined;
	let autoSwarmBalance: bigint | undefined;

	let lastPrice: bigint | undefined;
	let duration: number | undefined;
	let until: number | undefined;

	let topping = false;

	const refreshDisplay = async () => {
		console.log('refreshDisplay');
		if (!($bzzChainId > 0)) return;

		const block = await readBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;

		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance($bzzChainId, walletAddress);

		autoSwarmAddress = await readNftTBAccount($bzzChainId, collection, tokenId);
		autoSwarmBalance = await readBzzBalance($bzzChainId, autoSwarmAddress);
		lastPrice = (await readLastPrice($bzzChainId)) || DEFAULT_PRICE;

		if (autoSwarmBalance !== undefined && lastPrice > 0n) {
			duration = Number((autoSwarmBalance * BigInt(ONE_YEAR)) / AUTOSWARM_UNIT_PRICE);
			until = blockTimestamp + duration;
		}
	};

	const topUp = async () => {
		console.info('topUp');
		if (topping) return;

		if (lastPrice === undefined) {
			utilsError('No price found');
			return;
		}
		if (autoSwarmAddress === undefined || autoSwarmAddress == zeroAddress) {
			utilsError('Bad TBA address');
			return;
		}

		await writeTransferBzz($bzzChainId, autoSwarmAddress, AUTOSWARM_UNIT_PRICE);

		topping = false;
		refreshDisplay();
	};

	onMount(async () => {
		nftMetadataJson = await readNftMetadata(nftChainId, collection, tokenId);
		refreshDisplay();
	});
</script>

<section>
	<div class="nfts-grid">
		<article>
			{#if nftMetadataJson}
				<div
					title="NFT Collection Address  @{nftMetadataJson.address}"
					class="nft-img"
					style="background-image: url({nftMetadataJson.image});"
					aria-label={nftMetadataJson.description}
				/>
				<p class="nft-title">{nftMetadataJson.name} <span># {nftMetadataJson.tokenId}</span></p>
			{:else}
				<div class="nft-img" />
				<p class="nft-title">*** <span>#*</span></p>
			{/if}
		</article>
	</div>
	<section class="user-config">
		<p class="intro-text">NFT selected, click on TopUp to increase NFT lifespan on Swarm</p>
	</section>
	<div class="batch-topUp">
		<p class="batch-topUp-title">Swarm Storage Guaranteed</p>
		<div class="batch-topUp-infos">
			<p>for</p>
			<p>{displayDuration(duration)}</p>
			<p>until</p>
			<p>{displayDate(until)}</p>
		</div>
		<button class="btn btn-topup" on:click={topUp}>
			TopUp 1 Year
			{#if topping}
				<i class="fa-solid fa-spinner fa-spin-pulse" />
			{/if}
		</button>
		<div class="batch-topUp-below">
			<p>Price: {displayBalance(AUTOSWARM_UNIT_PRICE, 16)} Bzz / Mo</p>
		</div>
	</div>
</section>

<p>
	<a class="details-link" href="{$page.url.pathname}/details">details</a>
</p>
