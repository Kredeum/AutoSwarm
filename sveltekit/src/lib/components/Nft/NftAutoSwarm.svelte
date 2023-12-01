<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';

	import {
		ONE_YEAR,
		STAMP_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK
	} from '$lib/ts/constants/constants.js';
	import type { NftMetadata, NftMetadataAutoSwarm } from '$lib/ts/constants/types';
	import { localConfigInit } from '$lib/ts/common/local';
	import { fetchBzzTar } from '$lib/ts/fetch/fetchBzzTar';
	import { callBlock } from '$lib/ts/call/call.js';
	import { callTbaBzzHash } from '$lib/ts/call/callTba';
	import { callBzzBalance } from '$lib/ts/call/callBzz.js';
	import { callPostageLastPrice } from '$lib/ts/call/callPostage.js';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendTbaInitialize, sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendRegistryCreateAccount } from '$lib/ts/send/sendRegistry';
	import { displayBalance, displayDate, displayDuration } from '$lib/ts/display/display';

	import { utilsError, utilsIsBytes32Null } from '$lib/ts/common/utils.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	import Nft from '$lib/components/Nft/Nft.svelte';
	import NftDebug from '$lib/components/Nft/NftDebug.svelte';
	import { callTbaMetadata } from '$lib/ts/call/callTbaMetadata';

	////////////////////// AutoSwarm Component /////////////////////////////////
	// <AutoSwarm {nftChainId} {nftCollection} {nftTokenId} />
	////////////////////////////////////////////////////////////////////////////
	// - nftChainId    : NFT Chain Id
	// - nftCollection : NFT Collection Address
	// - nftTokenId    : NFT Token Id
	////////////////////////////////////////////////////////////////////////////
	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	////////////////////////////////////////////////////////////////////////////

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	let nftMetadata: NftMetadata;

	let tbaAddress: Address | undefined;

	let nftResaved: boolean;

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

	const showAlert = (message: string) =>
		setTimeout(() => {
			alert(message);
		}, 0);

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		oneDayNBal = undefined;
		owner = undefined;
	};

	const refresh = async () => {
		console.info('<NftAutoSwarm refresh  IN', $bzzChainId, nftChainId, nftCollection, nftTokenId);
		try {
			const metadata = await callTbaMetadata($bzzChainId, nftChainId, nftCollection, nftTokenId);
			if (metadata) nftMetadata = metadata;
		} catch (e) {
			utilsError('<NftAutoSwarm refresh', e);
		}
		if (!nftMetadata?.autoSwarm) return;
		reset();
		console.info('<NftAutoSwarm refresh ongoing...');

		tbaAddress = nftMetadata.autoSwarm.tbaAddress;

		const tbaBzzHash = await callTbaBzzHash($bzzChainId, tbaAddress);
		nftResaved = !utilsIsBytes32Null(tbaBzzHash);

		// Block
		const block = await callBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		// PostageStamp
		lastPrice = (await callPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;

		const tbaBalance = await callBzzBalance($bzzChainId, tbaAddress);
		if (tbaBalance !== undefined && lastPrice > 0n) {
			duration = Number((tbaBalance * BigInt(ONE_YEAR)) / STAMP_UNIT_PRICE);
			until = blockTimestamp + duration;
		}

		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);

		console.info('<NftAutoSwarm refresh OUT');
	};

	const createAccount = async () =>
		await sendRegistryCreateAccount($bzzChainId, nftChainId, nftCollection, nftTokenId);

	const initializeAccount = async () =>
		await sendTbaInitialize($bzzChainId, tbaAddress, nftMetadata?.autoSwarm?.bzzHash);

	const sendBzzTransferUnit = async () =>
		await sendBzzTransfer($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);

	const topUpStamp = async () => {
		if (lastPrice === undefined) throw Error('No price found');
		await sendTbaTopUp($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);
	};

	const reSaveNft = async () => {
		if (!nftMetadata?.autoSwarm) return;

		[
			nftMetadata.autoSwarm.bzzHash,
			[nftMetadata.autoSwarm.tbaImage, nftMetadata.autoSwarm.tbaTokenUri],
			[nftMetadata.autoSwarm.tbaImageSize, nftMetadata.autoSwarm.tbaTokenUriSize]
		] = await fetchBzzTar([nftMetadata.autoSwarm.nftImage, nftMetadata.autoSwarm.nftTokenUri]);

		console.log('reSaveNft ~ bzzHash:', nftMetadata.autoSwarm.bzzHash);
		console.log(
			'reSaveNft ~ tbaImage:',
			nftMetadata.autoSwarm.tbaImage,
			nftMetadata.autoSwarm.tbaImageSize
		);
		console.log(
			'reSaveNft ~ tbaTokenUri:',
			nftMetadata.autoSwarm.tbaTokenUri,
			nftMetadata.autoSwarm.tbaTokenUriSize
		);
	};

	const reSave = async () => {
		console.info('reSave');

		try {
			if (resaving) throw Error('Already ReSaving!');
			await reSaveNft();
			resaving = 1;
			await sendBzzTransferUnit();
			resaving = 2;
			await createAccount();
			resaving = 3;
			await initializeAccount();
			resaving = 4;
			showAlert('Your NFT has been ReSaved on Swarm! 🎉');
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
			toping = 2;
			showAlert('Your NFT has been TopUped on Swarm! 🎉');
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

{#key [toping, resaving, nftResaved]}
	<section id="resaver">
		<div class="nfts-grid">
			<Nft {nftChainId} {nftCollection} {nftTokenId} {nftMetadata} />

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
		</div>
	</section>

	<br />
	{#if nftResaved}
		<p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
	{:else}
		<p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
	{/if}
	<br />

	<p>
		<button class="btn" on:click={() => (debug = !debug)}>
			{#if debug}hide{/if} debug
		</button>
	</p>

	{#if debug}
		<NftDebug bzzChainId={$bzzChainId} {nftChainId} {nftCollection} {nftTokenId} {nftMetadata} />
	{/if}
{/key}
