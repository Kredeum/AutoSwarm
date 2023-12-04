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
	import { nftIds } from '$lib/ts/common/nft';

	////////////////////// AutoSwarm Component /////////////////////////////////
	// <AutoSwarm {metadata} />
	//////////////////////////////////////////////////////////////////////////////
	export let nftMetadata: NftMetadata;
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
		console.info('<NftAutoSwarm refresh  IN', $bzzChainId, nftMetadata);
		try {
			metadata = await callTbaMetadata($bzzChainId, nftMetadata);
		} catch (e) {
			utilsError('<NftAutoSwarm TBA refresh', e);
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

		const tbaBalance = metadata.autoSwarm.tbaBalance;
		const bzzPrice = metadata.autoSwarm.bzzPrice;
		if (tbaBalance !== undefined && bzzPrice && bzzPrice > 0) {
			duration = Number((tbaBalance * BigInt(ONE_YEAR)) / bzzPrice);
		}

		console.info('<NftAutoSwarm refresh OUT');
	};

	const createAccount = async () =>
		await sendRegistryCreateAccount($bzzChainId, ...nftIds(nftMetadata.autoSwarm));

	const initializeAccount = async () =>
		await sendTbaInitialize(
			$bzzChainId,
			tbaAddress,
			metadata?.autoSwarm?.bzzHash,
			metadata?.autoSwarm?.bzzSize
		);

	const sendBzzTransferOneYear = async () =>
		await sendBzzTransfer($bzzChainId, tbaAddress, metadata?.autoSwarm?.bzzPrice);

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
			refresh();
			await sendBzzTransferOneYear();
			resaving = 2;
			refresh();
			await createAccount();
			resaving = 3;
			refresh();
			await initializeAccount();
			// showAlert('Your NFT has been ReSaved on Swarm! 🎉');
			refresh();
		} catch (e) {
			utilsError(`ReSave (${resaving}/3) :`, e);
		}
		resaving = 0;
	};

	const topUp = async () => {
		console.info('topUp');

		try {
			if (toping) throw Error('Already Topping Up!');

			await sendBzzTransferOneYear();
			toping = 1;
			refresh();
			await topUpStamp();
			toping = 2;
			// showAlert('Your NFT has been TopUped on Swarm! 🎉');
			refresh();
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
						<p>Price: {displayBalance(metadata?.autoSwarm?.bzzPrice, 16, 3)} Bzz</p>
						<p><small>({displayBalance(STAMP_UNIT_PRICE, 16, 3)} Bzz / Ko / Year)</small></p>
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
		<NftDebug bzzChainId={$bzzChainId} {metadata} />
	{/if}
{/key}
