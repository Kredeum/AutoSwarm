<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';

	import { ONE_YEAR, STAMP_PRICE, STAMP_SIZE } from '$lib/ts/constants/constants.js';
	import type { Metadata, NftMetadata, BzzMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { localConfigInit } from '$lib/ts/common/local';
	import { fetchBzzTar, fetchBzzTarPost } from '$lib/ts/fetchBzz/fetchBzzTar';
	import { callBlock } from '$lib/ts/call/call.js';
	import { callTbaBzzHash } from '$lib/ts/call/callTba';

	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendTbaSetAutoSwarm, sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendRegistryCreateAccount } from '$lib/ts/send/sendRegistry';
	import {
		displayBalance,
		displayDate,
		displayDuration,
		displaySize
	} from '$lib/ts/display/display';

	import { utilsDivUp, utilsIsBytes32Null } from '$lib/ts/common/utils.js';
	import { tbaChainId, bzzImageName } from '$lib/ts/swarm/bzz';
	import { alertError, alertInfo, alertMessage, alertSuccess } from '$lib/ts/stores/alertMessage';

	import Nft from '$lib/components/Nft/Nft.svelte';
	import NftDetails from '$lib/components/Nft/NftDetails.svelte';
	import { callTbaMetadata } from '$lib/ts/call/callTbametadata';
	import { nftIds } from '$lib/ts/common/nft';
	import { fetchBzzMetadata } from '$lib/ts/fetch/fetchBzzMetadata';

	////////////////////// AutoSwarm Component /////////////////////////////////
	// <AutoSwarm {metadata} {nftMetadata} />
	//////////////////////////////////////////////////////////////////////////////
	export let metadata: Metadata;
	export let nftMetadata: NftMetadata;
	////////////////////////////////////////////////////////////////////////////

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	let bzzMetadata: BzzMetadata;
	let tbaMetadata: TbaMetadata;
  $: bzzMetadata && console.info('bzzMetadata:\n', bzzMetadata);
  $: tbaMetadata && console.info('tbaMetadata:\n', tbaMetadata);

	let tbaAddress: Address | undefined;
	let tbaDeployed: boolean | undefined;
	let resaveGaranteed: boolean;

	let duration: number | undefined;
	let until: number | undefined;

	// State
	let details = false;
	let oneYearPrice: bigint | undefined;

	let resaving = 0;
	let toping = 0;

	$: resaving, toping, refresh();

	const refresh = async () => {
		console.info('<NftMetadata refresh  IN', $tbaChainId, resaving, toping);

		try {
			tbaMetadata = await callTbaMetadata($tbaChainId, nftMetadata);
		} catch (e) {
			alertError('<NftMetadata refresh', e);
		}
		console.info('<NftMetadata refresh ongoing...');
		console.info(tbaMetadata);

		// Block
		{
			const block = await callBlock($tbaChainId);
			blockTimestamp = Number(block.timestamp) || 0;
			blockNumber = Number(block.number) || 0;
		}

		// TBA
		{
			tbaAddress = tbaMetadata.tbaAddress;
			tbaDeployed = tbaMetadata.tbaDeployed;
			if (tbaDeployed) {
				const tbaBzzHash = await callTbaBzzHash($tbaChainId, tbaAddress);
				resaveGaranteed = !utilsIsBytes32Null(tbaBzzHash);
			}

			const tbaBalance = tbaMetadata.tbaBalance;
			oneYearPrice = bzzMetadata.bzzPrice || 0n;
			if (tbaBalance !== undefined && oneYearPrice && oneYearPrice > 0n) {
				duration = Number((tbaBalance * BigInt(ONE_YEAR)) / oneYearPrice);
				until = blockTimestamp + duration;
			}
		}

		console.info('<NftMetadata refresh OUT');
	};

	const createAccount = async () =>
		await sendRegistryCreateAccount($tbaChainId, ...nftIds(nftMetadata));

	const tbaSetAutoSwarm = async () =>
		await sendTbaSetAutoSwarm($tbaChainId, tbaAddress, bzzMetadata.bzzHash, bzzMetadata.bzzSize);

	const transferBzzAmount = async (amount: bigint | undefined) =>
		await sendBzzTransfer($tbaChainId, tbaAddress, amount);

	const transferBzzOneYear = async () => await transferBzzAmount(oneYearPrice);

	const topUpStamp = async () => {
		await sendTbaTopUp($tbaChainId, tbaAddress, STAMP_PRICE);
	};

	const reSave = async () => {
		console.info('reSave');

		try {
			if (resaving) throw new Error('Already ReSaving!');

			resaving = 1;
			bzzMetadata = await fetchBzzMetadata(nftMetadata, true);

			resaving = 2;
			alertInfo(`Confirm transaction to create Token Bound Account (TBA)`);
			await createAccount();

			resaving = 3;
			alertInfo(
				`Confirm transaction to transfer ${displayBalance(oneYearPrice, 16, 3)} BZZ to TBA`
			);
			await transferBzzOneYear();

			alertSuccess(`Your NFT has been ReSaved on Swarm! 🎉'`);
		} catch (e) {
			alertError(`ReSave (${resaving - 1}/2) :`, e);
		}
		resaving = 0;
	};

	const topUp = async () => {
		console.info('topUp');

		try {
			if (toping) throw new Error('Already Topping Up!');
			toping = 1;
			alertInfo(`Confirm transaction and pay ${displayBalance(oneYearPrice, 16, 3)} BZZ to TopUp`);
			await transferBzzOneYear();

			toping = 1;
			alertSuccess('Your NFT has been TopUped on Swarm! 🎉');
		} catch (e) {
			alertError(`TopUp`, e);
		}

		toping = 0;
	};

	onMount(async () => {
		localConfigInit();

		console.info('<NftMetadata onMount metadata:\n', metadata);
		console.info('nftMetadata:\n', nftMetadata);

		bzzMetadata = await fetchBzzMetadata(nftMetadata);

	});
</script>

<section id="resaver">
	<div class="nfts-grid">
		<Nft {metadata} {nftMetadata} />

		{#if tbaDeployed !== undefined}
			<div class="batch-topUp">
				{#if tbaDeployed}
					<br />

					{#if duration == 0}
						<button class="btn btn-storage">Storage NOT Guaranteed</button>
						<br />
					{:else}
						<button class="btn btn-storage"
							>Storage {resaveGaranteed ? 'Guaranteed' : 'Estimation'}</button
						>
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
							<i class="fa-solid fa-spinner fa-spin-pulse" />
						{/if}
					</button>
				{:else}
					<button class="btn btn-topup" on:click={reSave}>
						ReSave NFT
						{#if resaving}
							&nbsp;
							<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {resaving - 1}/2
						{/if}
					</button>
				{/if}
				<div class="batch-topUp-below">
					<p>Price: {displayBalance(oneYearPrice, 16, 2)} Bzz</p>
					<p><small>({displayBalance(STAMP_PRICE, 16, 2)} BZZ / Mb / Year)</small></p>
				</div>
			</div>
		{/if}
	</div>
</section>

<br />
{#if tbaDeployed}
	<p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
{:else}
	<p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
{/if}
<br />

<p>
	<button class="btn" on:click={() => (details = !details)}>
		{#if details}hide{/if} details
	</button>
</p>

{#if details}
	<NftDetails tbaChainId={$tbaChainId} {metadata} {nftMetadata} {bzzMetadata} {tbaMetadata} />
{/if}
