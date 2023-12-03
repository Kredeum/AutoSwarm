<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';

	import {
		ONE_YEAR,
		STAMP_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK,
		STAMP_UNIT
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

	import { utilsDivUp, utilsError, utilsIsBytes32Null } from '$lib/ts/common/utils.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	import Nft from '$lib/components/Nft/Nft.svelte';
	import NftDebug from '$lib/components/Nft/NftDebug.svelte';
	import { callTbaMetadata } from '$lib/ts/call/callTbaMetadata';
	import { callNftMetadata } from '$lib/ts/call/callNftMetadata';

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

	let metadata: NftMetadata;

	let tbaAddress: Address | undefined;

	let nftResaved: boolean;

	let owner: Address | undefined;
	let depth: number;
	let duration: number | undefined;
	let until: number | undefined;
	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;

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
		owner = undefined;
	};

	const refresh = async () => {
		console.info('<NftAutoSwarm refresh  IN', $bzzChainId, nftChainId, nftCollection, nftTokenId);
		try {
			const nftMetadata = await callNftMetadata(nftChainId, nftCollection, nftTokenId);
			const tbaMetadata = await callTbaMetadata(
				$bzzChainId,
				nftChainId,
				nftCollection,
				nftTokenId,
				nftMetadata
			);
			if (tbaMetadata) metadata = tbaMetadata;
		} catch (e) {
			utilsError('<NftAutoSwarm refresh', e);
		}

		if (!metadata?.autoSwarm) return;
		reset();
		console.info('<NftAutoSwarm refresh ongoing...');

		tbaAddress = metadata.autoSwarm.tbaAddress;

		const tbaBzzHash = await callTbaBzzHash($bzzChainId, tbaAddress);
		nftResaved = !utilsIsBytes32Null(tbaBzzHash);

		// Block
		const block = await callBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		const tbaBalance = await callBzzBalance($bzzChainId, tbaAddress);
		if (tbaBalance !== undefined) {
			duration = Number((tbaBalance * BigInt(ONE_YEAR)) / STAMP_UNIT_PRICE);
		}

		console.info('<NftAutoSwarm refresh OUT');
	};

	const createAccount = async () =>
		await sendRegistryCreateAccount($bzzChainId, nftChainId, nftCollection, nftTokenId);

	const initializeAccount = async () =>
		await sendTbaInitialize(
			$bzzChainId,
			tbaAddress,
			metadata?.autoSwarm?.bzzHash,
			metadata?.autoSwarm?.bzzSize
		);

	const sendBzzTransferUnit = async () =>
		await sendBzzTransfer($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);

	const topUpStamp = async () => {
		await sendTbaTopUp($bzzChainId, tbaAddress, STAMP_UNIT_PRICE);
	};

	const reSaveNft = async () => {
		if (!metadata?.autoSwarm) return;

		[
			metadata.autoSwarm.bzzHash,
			metadata.autoSwarm.bzzSize,
			[metadata.autoSwarm.tbaImage, metadata.autoSwarm.tbaTokenUri],
			[metadata.autoSwarm.nftImageSize, metadata.autoSwarm.nftTokenUriSize]
		] = await fetchBzzTar([metadata.autoSwarm.nftImage, metadata.autoSwarm.nftTokenUri]);

		console.log('reSaveNft ~ bzzHash:', metadata.autoSwarm.bzzHash);
		console.log(
			'reSaveNft ~ tbaImage:',
			metadata.autoSwarm.tbaImage,
			metadata.autoSwarm.nftImageSize
		);
		console.log(
			'reSaveNft ~ tbaTokenUri:',
			metadata.autoSwarm.tbaTokenUri,
			metadata.autoSwarm.nftTokenUriSize
		);
		metadata.autoSwarm.bzzPrice =
			utilsDivUp(metadata.autoSwarm.bzzSize, STAMP_UNIT) * STAMP_UNIT_PRICE;
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
			// showAlert('Your NFT has been ReSaved on Swarm! 🎉');
		} catch (e) {
			utilsError(`ReSave (${resaving}/3) :`, e);
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
			// showAlert('Your NFT has been TopUped on Swarm! 🎉');
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
			<Nft {metadata} />

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
								<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {resaving}/3
							{/if}
						</button>
					{/if}
					<div class="batch-topUp-below">
						<p>Price: {displayBalance(metadata?.autoSwarm?.bzzPrice)} Bzz</p>
						<p><small>({displayBalance(STAMP_UNIT_PRICE, 16)} Bzz / Mo)</small></p>
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
		<NftDebug bzzChainId={$bzzChainId}   {metadata} />
	{/if}
{/key}
