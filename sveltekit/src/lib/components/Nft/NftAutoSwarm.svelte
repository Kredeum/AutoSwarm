<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';

	import { ONE_YEAR, STAMP_PRICE, STAMP_SIZE } from '$lib/ts/constants/constants.js';
	import type { Metadata, NftMetadata, BeeMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { localConfigInit } from '$lib/ts/common/local';
	import { fetchNftTar } from '$lib/ts/fetchBee/fetchNftTar';
	import { fetchBeeTarPost } from '$lib/ts/fetchBee/fetchBeeTar';
	import { callBlock } from '$lib/ts/call/call.js';
	import { callTbaSwarmHash } from '$lib/ts/call/callTba';

	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendTbaSetAutoSwarm, sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendRegistryCreateAccount } from '$lib/ts/send/sendRegistry';
	import {
		displayBalance,
		displayDate,
		displayDuration,
		displaySize
	} from '$lib/ts/display/display';

	import { utilsDivUp, utilsBytes32Null } from '$lib/ts/common/utils.js';
	import { bzzChainId, nftImageName } from '$lib/ts/swarm/bzz';
	import { alertError, alertInfo, alertMessage, alertSuccess } from '$lib/ts/stores/alertMessage';

	import Nft from '$lib/components/Nft/Nft.svelte';

	import { callTbaMetadata } from '$lib/ts/call/callTbametadata';
	import { nftIds } from '$lib/ts/common/nft';
	import { fetchBeeMetadata } from '$lib/ts/fetch/fetchBeeMetadata';
	import DetailsNft from '../Details/DetailsNft.svelte';
	import DetailsBee from '../Details/DetailsBee.svelte';
	import DetailsTba from '../Details/DetailsTba.svelte';
	import DetailsPostage from '../Details/DetailsPostage.svelte';
	import DetailsWallet from '../Details/DetailsWallet.svelte';

	////////////////////// AutoSwarm Component /////////////////////////////////
	// <AutoSwarm {metadata} {nftMetadata} />
	//////////////////////////////////////////////////////////////////////////////
	export let metadata: Metadata;
	export let nftMetadata: NftMetadata;
	////////////////////////////////////////////////////////////////////////////

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	let beeMetadata: BeeMetadata = {};
	let tbaMetadata: TbaMetadata = {};

	let tbaDeployed: boolean | undefined;
	let tbaAddress: Address | undefined;
	let resaveGaranteed: boolean;

	let duration: number | undefined;
	let until: number | undefined;

	// State
	let details = false;
	let oneYearPrice: bigint;

	let resaving: number;
	let toping: number;

	const refresh = async () => {
		if (!($bzzChainId && nftMetadata)) return;
		console.info('<NftMetadata refresh  IN', $bzzChainId);

		try {
			tbaMetadata = await callTbaMetadata($bzzChainId, ...nftIds(nftMetadata));
			console.info('tbaMetadata', tbaMetadata);

			({ tbaDeployed, tbaAddress } = tbaMetadata);
			resaveGaranteed = !utilsBytes32Null(tbaMetadata.tbaSwarmHash);

			// Block
			{
				const block = await callBlock($bzzChainId);
				blockTimestamp = Number(block.timestamp) || 0;
				blockNumber = Number(block.number) || 0;
			}

			// Duration
			{
				oneYearPrice = nftMetadata.nftPrice || 0n;
				if (tbaMetadata.tbaBalance !== undefined && oneYearPrice && oneYearPrice > 0n) {
					duration = Number((tbaMetadata.tbaBalance * BigInt(ONE_YEAR)) / oneYearPrice);
					until = blockTimestamp + duration;
				}
			}
		} catch (e) {
			console.error('<NftMetadata refresh', e);
			alertError('NftMetadata Refresh Error', e);
		}
		console.info('<NftMetadata refresh OUT');
	};

	const reSave = async () => {
		console.info('reSave');

		try {
			if (resaving) throw new Error('Already ReSaving!');

			{
				resaving = 1;
				beeMetadata = await fetchBeeMetadata(nftMetadata);
				console.info('beeMetadata\n', beeMetadata);
				refresh();
			}

			{
				resaving = 2;
				alertInfo(`Confirm transaction to create Token Bound Account (TBA)`);
				await sendRegistryCreateAccount($bzzChainId, ...nftIds(nftMetadata));
				refresh();
			}

			{
				resaving = 3;
				alertInfo(
					`Confirm transaction to transfer ${displayBalance(oneYearPrice, 16, 3)} BZZ to TBA`
				);
				await sendBzzTransfer($bzzChainId, tbaAddress, oneYearPrice);
				refresh();
			}

			{
				resaving = 4;
				alertInfo(`Confirm transaction to setup your TBA`);
				await sendTbaSetAutoSwarm(
					$bzzChainId,
					tbaAddress,
					nftMetadata.nftSize,
					beeMetadata.beeHash
				);

				refresh();
			}

			{
				resaving = 5;
				alertSuccess(`Your NFT has been ReSaved on Swarm! 🎉'`);
			}
		} catch (e) {
			alertError(`ReSave (${resaving - 1}/3) :`, e);
		}
		resaving = 0;
	};

	const topUp = async () => {
		console.info('topUp');

		try {
			if (toping) throw new Error('Already Topping Up!');

			{
				toping = 1;
				alertInfo(`Confirm transfer of ${displayBalance(oneYearPrice, 16, 3)} BZZ to TBA`);
				await sendBzzTransfer($bzzChainId, tbaAddress, oneYearPrice);
				refresh();
			}

			{
				toping = 2;
				alertSuccess('Your NFT has been TopUped on Swarm! 🎉');
			}
		} catch (e) {
			alertError(`TopUp`, e);
		}

		toping = 0;
	};

	onMount(async () => {
		console.info('metadata:\n', metadata);
		console.info('nftMetadata:\n', nftMetadata);

		refresh();
	});
</script>

<section id="resaver">
	<div class="nfts-grid">
		<Nft {metadata} {nftMetadata} />

		<div class="batch-topUp">
			{#if tbaDeployed && !resaving}
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
						<i class="fa-solid fa-spinner fa-spin-pulse" /> &nbsp; {resaving - 1}/3
					{/if}
				</button>
			{/if}
			<div class="batch-topUp-below">
				<p>Price: {displayBalance(oneYearPrice, 16, 2)} Bzz</p>
				<p><small>({displayBalance(STAMP_PRICE, 16, 2)} BZZ / Mb / Year)</small></p>
			</div>
		</div>
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
	<div id="details">
		<hr />
		<DetailsNft {nftMetadata} />
		<hr />
		<DetailsBee {beeMetadata} />
		<hr />
		<DetailsTba {tbaMetadata} />
		<hr />
		<DetailsPostage />
		<hr />
		<DetailsWallet />
		<hr />
	</div>
{/if}

<style>
	#details {
		width: 1100px;
		display: block;
		text-align: left;
	}
</style>
