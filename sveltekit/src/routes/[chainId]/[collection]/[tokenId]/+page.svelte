<script lang="ts">
	import { zeroAddress, type Address, type Hex } from 'viem';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';

	import {
		ONE_YEAR,
		STAMP_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK,
		type NftMetadata
	} from '$lib/ts/constants/constants.js';

	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { callBlock, callIsContract } from '$lib/ts/call/call.js';
	import { callBzzBalance } from '$lib/ts/call/callBzz.js';
	import { callPostageLastPrice } from '$lib/ts/call/callPostage.js';
	import { displayBalance, displayDate, displayDuration } from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { callRegistryAccount } from '$lib/ts/call/callRegistry.js';
	import { sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendRegistryCreateAccount } from '$lib/ts/send/sendRegistry';
	import Debug from '$lib/components/Debug/Debug.svelte';
	import Nft from '$lib/components/Nft/Nft.svelte';
	import { fetchBzzPost } from '$lib/ts/fetch/fetchBzz';

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	// NFT
	const nftChainId = Number($page.params.chainId);
	const nftCollection = $page.params.collection as Address;
	const nftTokenId = BigInt($page.params.tokenId);
	let nftMetadata: NftMetadata;

	// TBA
	let tbaAddress: Address | undefined;

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
	let tbaDeployed: boolean | undefined;
	let debug = false;
	let initializing = false;
	let resaving = false;
	let topping = false;

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		oneDayNBal = undefined;
		tbaAddress = undefined;
		owner = undefined;
	};

	const refresh = async () => {
		console.log('refresh');
		if (!($bzzChainId > 0)) return;
		reset();

		// Block
		const block = await callBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		// TBA
		tbaAddress = await callRegistryAccount($bzzChainId, nftChainId, nftCollection, nftTokenId);

		// PostageStamp
		lastPrice = (await callPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;

		const tbaBalance = await callBzzBalance($bzzChainId, tbaAddress);
		if (tbaBalance !== undefined && lastPrice > 0n) {
			duration = Number((tbaBalance * BigInt(ONE_YEAR)) / STAMP_UNIT_PRICE);
			until = blockTimestamp + duration;
		}

		// remainingBalance = await callPostageRemainingBalance($bzzChainId);
		// [owner, depth, normalisedBalance] =
		// 	$bzzChainId == 100
		// 		? await callPostageBatchesLegacy($bzzChainId)
		// 		: await callPostageBatches($bzzChainId);

		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);

		tbaDeployed = await callIsContract($bzzChainId, tbaAddress as Address);
		console.log('refresh ~ tbaDeployed:', tbaDeployed);
	};

	const reSave = async () => {
		resaving = true;
		try {
			nftMetadata.imageResave = await fetchBzzPost(nftMetadata.imageAlt, '0x0');

			// await sendRegistryCreateAccount($bzzChainId, nftChainId, nftCollection, nftTokenId);
			// await topUp();
		} catch (e) {
			alert(e);
		}
		resaving = false;
	};

	const topUp = async () => {
		console.info('topUp');
		topping = true;

		if (lastPrice === undefined) {
			utilsError('No price found');
			return;
		}
		if (tbaAddress === undefined || tbaAddress == zeroAddress) {
			utilsError('Bad TBA address');
			return;
		}

		try {
			await sendBzzTransfer($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);
			await sendTbaTopUp($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);
		} catch (e) {
			alert(e);
		}
		topping = false;

		refresh();
	};

	onMount(refresh);
</script>

<section>
	<div class="nfts-grid">
		<Nft {nftChainId} {nftCollection} {nftTokenId} bind:nftMetadata />
	</div>
	<section class="user-config">
		{#if tbaDeployed}
			<p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
		{:else}
			<p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
		{/if}
	</section>

	{#if tbaDeployed !== undefined}
		<div class="batch-topUp">
			{#if tbaDeployed}
				<br />

				{#if duration == 0}
					<button class="btn btn-storage">Storage NOT Guaranteed</button>
					<br />
				{:else}
					<button class="btn btn-storage">Storage Guaranteed</button>
					<br />
					<div class="batch-topUp-infos">
						<p>for</p>
						<p>{displayDuration(duration)}</p>
						<p>until</p>
						<p>{displayDate(until)}</p>
					</div>
				{/if}

				<br />

				<button class="btn btn-topup" on:click={topUp}>
					TopUp 1 Year
					{#if topping}
						<i class="fa-solid fa-spinner fa-spin-pulse" />
					{/if}
				</button>
			{:else}
				<button class="btn btn-topup" on:click={reSave}>
					ReSave NFT
					{#if resaving}
						<i class="fa-solid fa-spinner fa-spin-pulse" />
					{/if}
				</button>
			{/if}
			<div class="batch-topUp-below">
				<p>Price: {displayBalance(STAMP_UNIT_PRICE, 16)} Bzz / Mo</p>
			</div>
		</div>
	{/if}

	<br />
	<br />

	<p>
		<button class="btn" on:click={() => (debug = !debug)}>
			{#if debug}hide{/if} debug
		</button>
	</p>

	{#if debug}
		<Debug bzzChainId={$bzzChainId} {nftChainId} {nftCollection} {nftTokenId} {nftMetadata} />
	{/if}
</section>
