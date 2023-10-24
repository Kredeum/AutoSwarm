<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';

	import { zeroAddress, type Address } from 'viem';

	import {
		type NftMetadata,
		ONE_YEAR,
		AUTOSWARM_UNIT_PRICE,
		DEFAULT_PRICE
	} from '$lib/ts/constants.js';
	import { writeTransferBzz, writeWalletAddress } from '$lib/ts/write';
	import {
		readAccount,
		readBlock,
		readBzzBalance,
		readLastPrice,
		readNftMetadata
	} from '$lib/ts/read.js';
	import { displayBalance, displayDate, displayDuration, displayTxt } from '$lib/ts/display';
	import { utilsError } from '$lib/ts/utils.js';

	export let data;
	const { chain } = data;

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
		if (!chain) return;

		const block = await readBlock(chain);
		blockTimestamp = Number(block.timestamp) || 0;

		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance(chain, walletAddress);

		autoSwarmAddress = await readAccount(chain);
		autoSwarmBalance = await readBzzBalance(chain, autoSwarmAddress);
		lastPrice = (await readLastPrice(chain)) || DEFAULT_PRICE;

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

		await writeTransferBzz(chain, autoSwarmAddress, AUTOSWARM_UNIT_PRICE);

		topping = false;
		refreshDisplay();
	};

	onMount(async () => {
		nftMetadataJson = await readNftMetadata(chain);
		refreshDisplay();
	});
</script>

<p>
	Chain {data.chain.name}
</p>
<p>
	<a class="details-link" href="{$page.url.pathname}/details">details</a>
</p>

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
	{/if}
</section>
