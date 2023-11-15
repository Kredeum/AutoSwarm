<script lang="ts">
	import { zeroAddress, type Address, type Hex } from 'viem';
	import { onMount, getContext } from 'svelte';
	import { page } from '$app/stores';

	import {
		type NftMetadata,
		ONE_YEAR,
		AUTOSWARM_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK
	} from '$lib/ts/constants/constants.js';
	import { writeTransferBzz, writeWalletAddress } from '$lib/ts/onchain/write';
	import { readBlock, readIsContract } from '$lib/ts/onchain/read.js';
	import { readBzzBalance } from '$lib/ts/onchain/readBzz.js';
	import {
		readPostageBatchesLegacy,
		readPostageBatches,
		readPostageLastPrice,
		readPostageRemainingBalance
	} from '$lib/ts/onchain/readPostage.js';
	import { displayBalance, displayDate, displayDuration } from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils.js';
	import { readNftMetadata, readNftOwner, readNftTBAccount } from '$lib/ts/onchain/readNft.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { jsonGetField } from '$lib/ts/constants/json';
	import Header from '$lib/svelte/Header.svelte';
	import { readMarketCurrentBatchId } from '$lib/ts/onchain/readMarket';

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	// NFT
	const nftChainId = Number($page.params.chainId);
	const collection = $page.params.collection as Address;
	const tokenId = BigInt($page.params.tokenId);
	let nftMetadata: NftMetadata;
	let nftOwner: Address | undefined;

	// TBA
	let autoSwarmAddress: Address | undefined;
	let autoSwarmBalance: bigint | undefined;
	let tbaDeployed: boolean | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;

	// Batch
	let owner: Address | undefined;
	let depth: number;
	let duration: number | undefined;
	let until: number | undefined;
	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;

	// PostageStamp
	let lastPrice: bigint | undefined = 0n;
	let oneDayNBal: bigint | undefined;

	// State
	let details = false;
	let toReSave = true;
	let topping = false;
	let resaving = false;

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		autoSwarmBalance = undefined;
		oneDayNBal = undefined;
		autoSwarmAddress = undefined;
		owner = undefined;
		nftOwner = undefined;
		tbaDeployed = undefined;
		currentBatchId = undefined;
	};

	const refreshDisplay = async () => {
		console.log('refreshDisplay');
		if (!($bzzChainId > 0)) return;
		reset();

		// Block
		const block = await readBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		// Wallet
		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance($bzzChainId, walletAddress);

		// NFT
		nftOwner = await readNftOwner(nftChainId, collection, tokenId);

		// TBA
		autoSwarmAddress = await readNftTBAccount($bzzChainId, collection, tokenId);
		autoSwarmBalance = await readBzzBalance($bzzChainId, autoSwarmAddress);

		// AutoSwarmMarket
		currentBatchId = await readMarketCurrentBatchId($bzzChainId);

		// PostageStamp
		lastPrice = (await readPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;

		if (autoSwarmBalance !== undefined && lastPrice > 0n) {
			duration = Number((autoSwarmBalance * BigInt(ONE_YEAR)) / AUTOSWARM_UNIT_PRICE);
			until = blockTimestamp + duration;
		}

		// remainingBalance = await readPostageRemainingBalance($bzzChainId);
		// [owner, depth, normalisedBalance] =
		// 	$bzzChainId == 100
		// 		? await readPostageBatchesLegacy($bzzChainId)
		// 		: await readPostageBatches($bzzChainId);

		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);

		tbaDeployed = await readIsContract($bzzChainId, autoSwarmAddress as Address);

		toReSave = nftMetadata.tokenUriResave === undefined;
		console.log('refreshDisplay ~ toReSave:', toReSave);
	};

	const reSave = async () => {
		resaving = true;
		nftMetadata.tokenUriResave = nftMetadata.tokenUriAlt;
		await topUp();
		resaving = false;
		toReSave = false;
	};

	const topUp = async () => {
		console.info('topUp');
		if (topping) return;
		topping = true;

		if (lastPrice === undefined) {
			utilsError('No price found');
			return;
		}
		if (autoSwarmAddress === undefined || autoSwarmAddress == zeroAddress) {
			utilsError('Bad TBA address');
			return;
		}

		try {
			await writeTransferBzz($bzzChainId, autoSwarmAddress, AUTOSWARM_UNIT_PRICE);
		} catch (e) {
			alert(e);
		}

		topping = false;
		refreshDisplay();
	};

	onMount(async () => {
		try {
			nftMetadata = await readNftMetadata(nftChainId, collection, tokenId);
			refreshDisplay();
		} catch (e) {
			alert(e);
		}
	});
</script>

{#if nftMetadata}
	<section>
		<div class="nfts-grid">
			<article>
				<div
					title="NFT Collection Address  @{nftMetadata.address}"
					class="nft-img"
					style="background-image: url({nftMetadata.imageAlt});"
					aria-label={nftMetadata.description}
				/>
				<p class="nft-title">{nftMetadata.name} <span># {nftMetadata.tokenId}</span></p>
			</article>
		</div>
		<section class="user-config">
			{#if toReSave}
				<p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
			{:else}
				<p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
			{/if}
		</section>
		<div class="batch-topUp">
			{#if toReSave}
				<button class="btn btn-topup" on:click={reSave}>
					ReSave NFT
					{#if resaving}
						<i class="fa-solid fa-spinner fa-spin-pulse" />
					{/if}
				</button>
			{:else}
				<br />
				<p class="batch-topUp-title">AutoSwarm Storage Guaranteed</p>
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
			{/if}
			<div class="batch-topUp-below">
				<p>Price: {displayBalance(AUTOSWARM_UNIT_PRICE, 16)} Bzz / Mo</p>
			</div>
		</div>
		<br />
		<br />
		<p>
			<button class="btn" on:click={() => (details = !details)}>
				{#if details}hide{/if} details
			</button>
		</p>

		{#if nftMetadata && details}
			<div id="details">
        {currentBatchId}
				<p>
					tokenURI original <strong>{nftMetadata.tokenUriType}</strong><span
						>{nftMetadata.tokenUri}</span
					>
				</p>
				<p>tokenURI alternative<span>{nftMetadata.tokenUriAlt}</span></p>
				<p>tokenURI resaved<span>{nftMetadata.tokenUriResave}</span></p>
				<p>
					content original <strong>{nftMetadata.imageType}</strong><span>{nftMetadata.image}</span>
				</p>
				<p>content alternative<span>{nftMetadata.imageAlt}</span></p>
				<p>content resaved<span>{nftMetadata.imageResave}</span></p>
			</div>
		{/if}
	</section>
{/if}

<style>
	#details {
		width: 1100px;
		display: block;
		text-align: left;
	}
	#details p span {
		float: right;
	}
</style>
