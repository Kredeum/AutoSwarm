<script lang="ts">
	import { onMount } from 'svelte';
	import type { Address } from 'viem';

	import {
		type NftMetadata,
		ONE_YEAR,
		SECONDS_PER_BLOCK,
		AUTOSWARM_UNIT_PRICE,
		DEFAULT_PRICE
	} from '$lib/ts/constants.js';
	import { writeWalletAddress } from '$lib/ts/write';
	import { writeStampsTopUp } from '$lib/ts/writeStamps.js';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBlock,
		readBzzBalance,
		readLastPrice,
		readNftMetadata,
		readRemainingBalance
	} from '$lib/ts/read.js';
	import { getBatchId } from '$lib/ts/get';
	import { displayBalance, displayDate, displayDuration, displayTxt } from '$lib/ts/display';
	import { utilsError } from '$lib/ts/utils.js';

	export let data;
	const { chain } = data;

	let nftMetadataJson: NftMetadata;

	let batchId = getBatchId(100);
	let topping = false;

	let walletAddress: Address | undefined;
	let autoSwarmAddress: Address | undefined;
	let walletBalance: bigint | undefined;
	let autoSwarmBalance: bigint | undefined;
	let remainingBalance: bigint | undefined;
	let lastPrice: bigint | undefined;
	let duration: number | undefined;
	let until: number | undefined;
	let blockTimestamp: number | undefined;

	const refreshDisplay = async () => {
		console.log('refreshDisplay');

		// const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
		const timeZone = Intl.DateTimeFormat().resolvedOptions();
		console.log(timeZone); // output: "America/New_York"

		const block = await readBlock(chain);
		blockTimestamp = Number(block.timestamp) || 0;
		console.log('refreshDisplay ~ blockTimestamp:', blockTimestamp);

		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance(chain, walletAddress);
		autoSwarmAddress = await readAccount(chain);
		autoSwarmBalance = await readBzzBalance(chain, autoSwarmAddress);
		remainingBalance = await readRemainingBalance(chain);
		lastPrice = (await readLastPrice(chain)) || DEFAULT_PRICE;

		if (lastPrice > 0n) {
			duration = Number((remainingBalance * BigInt(SECONDS_PER_BLOCK)) / lastPrice);
			until = blockTimestamp + duration;
			console.log('refreshDisplay ~ duration:', duration);
			console.log('refreshDisplay ~ until:', until);
		}

		chain.id == 100 ? await readBatchLegacy(chain) : await readBatchNew(chain);
	};

	const topUp = async () => {
		if (topping) return;
		if (lastPrice === undefined) {
			utilsError('No price found');
			return;
		}
		console.info('topUp');

		await writeStampsTopUp(chain, (BigInt(ONE_YEAR) * lastPrice) / BigInt(SECONDS_PER_BLOCK));

		topping = false;
		refreshDisplay();
	};

	onMount(async () => {
		nftMetadataJson = await readNftMetadata(chain);
		refreshDisplay();
	});
</script>

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
			Chain {data.chain.name}
			<!-- <p>
      <a class="details-link" href="gnosis/details">gnosis</a> -
			<a class="details-link" href="sepolia/details">sepolia</a> -
			<a class="details-link" href="anvil/details">anvil</a>
		</p> -->
		</section>
		<div class="batch-topUp">
			<p class="batch-topUp-title">Swarm Storage Guaranteed</p>
			<div class="batch-topUp-infos">
				<p>for</p>
				<p title="{displayTxt(remainingBalance)} seconds">
					{displayDuration(duration)}
				</p>
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
				<p>
					{#if walletBalance}Your Balance: {displayBalance(walletBalance, 16)} Bzz{/if}
				</p>
			</div>
		</div>
	{/if}
</section>
