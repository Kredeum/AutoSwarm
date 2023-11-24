<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';

	import {
		ONE_YEAR,
		STAMP_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK
	} from '$lib/ts/constants/constants.js';

	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { callBlock, callIsContract } from '$lib/ts/call/call.js';
	import { callBzzBalance } from '$lib/ts/call/callBzz.js';
	import { callPostageLastPrice } from '$lib/ts/call/callPostage.js';
	import {
		displayBalance,
		displayDate,
		displayDuration,
		displayExplorerAddress,
		explorerAddress
	} from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { callRegistryAccount } from '$lib/ts/call/callRegistry.js';
	import { sendTbaInitialize, sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendRegistryCreateAccount } from '$lib/ts/send/sendRegistry';

	import Nft from '$lib/components/Nft/Nft.svelte';
	import { fetchBzzPost } from '$lib/ts/fetch/fetchBzz';
	import { localConfigInit } from '$lib/ts/constants/local';
	import { fetchBzzTar } from '$lib/ts/fetch/fetchBzzTar';
	import Debug from '$lib/components/Pages/Debug.svelte';
	import type { NftMetadata } from '$lib/ts/constants/types';

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	// NFT
	const nftChainId = Number($page.params.chainId);
	const nftCollection = $page.params.collection as Address;
	const nftTokenId = BigInt($page.params.tokenId);
	let nftMetadata: NftMetadata;

	$: autoSwarmMetadata = nftMetadata?.autoswarm;
	$: tbaAddress = autoSwarmMetadata?.tbaAddress;
	$: nftResaved = Boolean(autoSwarmMetadata?.bzzHash);

	$: console.info('nftResaved', nftResaved);
	$: console.info('nftMetadata', nftMetadata);
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
	let debug = false;

	let resaving = 0;
	let toping = 0;

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		oneDayNBal = undefined;
		owner = undefined;
	};

	const refresh = async () => {
		// console.info('refresh');
		if (!($bzzChainId > 0)) return;
		reset();

		// Block
		const block = await callBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		// PostageStamp
		lastPrice = (await callPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;
		console.log('refresh ~ lastPrice:', lastPrice);

		const tbaBalance = await callBzzBalance($bzzChainId, tbaAddress);
		if (tbaBalance !== undefined && lastPrice > 0n) {
			duration = Number((tbaBalance * BigInt(ONE_YEAR)) / STAMP_UNIT_PRICE);
			until = blockTimestamp + duration;
		}

		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);
	};

	const resaveTokenUri = async () => {
		if (!autoSwarmMetadata) return;

		autoSwarmMetadata.tbaTokenUri = (
			await fetchBzzPost(autoSwarmMetadata.nftTokenUriAlt)
		)?.toString();
	};

	const resaveImage = async () => {
		if (!autoSwarmMetadata) return;

		autoSwarmMetadata.tbaImageAlt = (await fetchBzzPost(autoSwarmMetadata.nftImageAlt))?.toString();
	};

	const createAccount = async () =>
		await sendRegistryCreateAccount($bzzChainId, nftChainId, nftCollection, nftTokenId);

	const initializeAccount = async () =>
		await sendTbaInitialize($bzzChainId, tbaAddress, autoSwarmMetadata?.bzzHash, STAMP_UNIT_PRICE);

	const sendBzzTransferUnit = async () =>
		await sendBzzTransfer($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);

	const topUpStamp = async () => {
		if (lastPrice === undefined) throw Error('No price found');
		await sendTbaTopUp($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);
	};

	const resaveNft = async () => {
		if (!autoSwarmMetadata) return;

		// [autoSwarmMetadata.bzzHash, [autoSwarmMetadata.tbaImageAlt, autoSwarmMetadata.tbaTokenUri]] =
		const [bzzHash, [tbaImageAlt, tbaTokenUri]] = await fetchBzzTar([
			autoSwarmMetadata.nftImageAlt,
			autoSwarmMetadata.nftTokenUriAlt
		]);
		autoSwarmMetadata.bzzHash = bzzHash;
		autoSwarmMetadata.tbaImageAlt = tbaImageAlt.toString();
		autoSwarmMetadata.tbaTokenUri = tbaTokenUri.toString();

		console.log('resaveNft ~ bzzHash:', autoSwarmMetadata.bzzHash);
		console.log('resaveNft ~ tbaImageAlt:', autoSwarmMetadata.tbaImageAlt);
		console.log('resaveNft ~ tbaTokenUri:', autoSwarmMetadata.tbaTokenUri);
	};

	const reSave = async () => {
		console.info('reSave');

		try {
			if (resaving) throw Error('Already ReSaving!');
			await resaveNft();
			resaving = 1;
			await sendBzzTransferUnit();
			resaving = 2;
			await createAccount();
			resaving = 3;
			await initializeAccount();
			alert('Your NFT has been ReSaved on Swarm! 🎉');
			resaving = 4;
		} catch (e) {
			utilsError(`ReSave (${resaving}/4) :`, e);
		}
		resaving = 0;
		refresh();
	};

	const topUp = async () => {
		console.info('topUp');

		try {
			if (toping) throw Error('Already Topping Up!');

			await sendBzzTransferUnit();
			toping = 1;
			await topUpStamp();
			alert('Your NFT has been TopUped on Swarm! 🎉');
			toping = 2;
		} catch (e) {
			utilsError(`TopUp (${toping}/2) :`, e);
		}

		toping = 0;
		refresh();
	};

	onMount(async () => {
		localConfigInit();
		await refresh();
	});
</script>

{#key [toping, resaving]}
	<section>
		{autoSwarmMetadata?.nftTokenUriAlt}
		<div class="nfts-grid">
			<Nft {nftChainId} {nftCollection} {nftTokenId} bind:nftMetadata />
		</div>
		<section class="user-config">
			{#if nftResaved}
				<p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
			{:else}
				<p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
			{/if}
		</section>

		{#if nftResaved !== undefined}
			<div class="batch-topUp">
				{#if nftResaved}
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
						{#if toping}
							&nbsp;
							<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {toping}/2
						{/if}
					</button>
				{:else}
					<button class="btn btn-topup" on:click={reSave}>
						ReSave NFT
						{#if resaving}
							&nbsp;
							<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {resaving}/4
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
{/key}
