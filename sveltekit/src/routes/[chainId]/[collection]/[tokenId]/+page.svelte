<script lang="ts">
	import { zeroAddress, type Address, type Hex } from 'viem';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';

	import {
		type NftMetadata,
		ONE_YEAR,
		STAMP_UNIT_PRICE,
		DEFAULT_PRICE,
		ONE_DAY,
		SECONDS_PER_BLOCK,
		ZERO_BYTES32,
		BATCH_UNIT_PRICE
	} from '$lib/ts/constants/constants.js';
	import { sendWalletAddress } from '$lib/ts/send/send';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { callBlock, callIsContract } from '$lib/ts/call/call.js';
	import { callBzzBalance } from '$lib/ts/call/callBzz.js';
	import {
		callPostageBatchesLegacy,
		callPostageBatches,
		callPostageLastPrice,
		callPostageRemainingBalance
	} from '$lib/ts/call/callPostage.js';
	import {
		displayBalance,
		displayDate,
		displayDuration,
		displayExplorer,
		displayExplorerAddress,
		displayExplorerField,
		displayLink
	} from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils.js';
	import { callNftMetadata, callNftOwner, callNftTBAccount } from '$lib/ts/call/callNft.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';
	import { sendTbaTopUp } from '$lib/ts/send/sendTba';
	import { sendMarketNewBatch } from '$lib/ts/send/sendMarket';
	import { jsonGetField } from '$lib/ts/constants/json';

	// Block
	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	// NFT
	const nftChainId = Number($page.params.chainId);
	const nftCollection = $page.params.collection as Address;
	const tokenId = BigInt($page.params.tokenId);
	let nftMetadata: NftMetadata;

	// TBA
	let tbaAddress: Address | undefined;
	let tbaBalance: bigint | undefined;
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
	let debug = false;
	let toReSave = false;
	let initializing = false;
	let resaving = false;
	let topping = false;
	let buying = false;

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		tbaBalance = undefined;
		oneDayNBal = undefined;
		tbaAddress = undefined;
		owner = undefined;
		tbaDeployed = undefined;
		currentBatchId = undefined;
	};

	const refreshDisplay = async () => {
		console.log('refreshDisplay');
		if (!($bzzChainId > 0)) return;
		reset();

		// Block
		const block = await callBlock($bzzChainId);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		// Wallet
		walletAddress = await sendWalletAddress();
		walletBalance = await callBzzBalance($bzzChainId, walletAddress);

		// TBA
		tbaAddress = await callNftTBAccount($bzzChainId, nftCollection, tokenId);
		tbaBalance = await callBzzBalance($bzzChainId, tbaAddress);

		// AutoSwarmMarket
		currentBatchId = await callMarketCurrentBatchId($bzzChainId);

		// PostageStamp
		lastPrice = (await callPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;

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

		toReSave = nftMetadata.tokenUriResave === undefined;
		console.log('refreshDisplay ~ toReSave:', toReSave);
	};

	const init = async () => {
		initializing = true;
		try {
		} catch (e) {
			alert(e);
		}
		initializing = false;
	};

	const newBatch = async () => {
		buying = true;
		try {
			const autoSwarmMarket = jsonGetField($bzzChainId, 'AutoSwarmMarket') as Address;
			await sendBzzTransfer($bzzChainId, autoSwarmMarket, BATCH_UNIT_PRICE);
			await sendMarketNewBatch($bzzChainId);
		} catch (e) {
			utilsError(`newBatch\n${e}`);
		}
		buying = false;
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
		} catch (e) {
			alert(e);
		}
		topping = false;

		refreshDisplay();
	};

	onMount(async () => {
		try {
			nftMetadata = await callNftMetadata(nftChainId, nftCollection, tokenId);
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
				<button class="btn btn-storage">Storage Guaranteed</button>
				<br />
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
				<p>Price: {displayBalance(STAMP_UNIT_PRICE, 16)} Bzz / Mo</p>
			</div>
		</div>
		<br />
		<br />
		<p>
			<button class="btn" on:click={() => (debug = !debug)}>
				{#if debug}hide{/if} debug
			</button>
		</p>

		{#if nftMetadata && debug}
			<div id="debug">
				<p>
					tokenURI original <strong>{nftMetadata.tokenUriType}</strong><span
						>{@html displayLink(nftMetadata.tokenUri)}</span
					>
				</p>
				<p>tokenURI alternative<span>{@html displayLink(nftMetadata.tokenUriAlt)}</span></p>
				<p>tokenURI resaved<span>{@html displayLink(nftMetadata.tokenUriResave)}</span></p>
				<p>
					content original <strong>{nftMetadata.imageType}</strong><span
						>{@html displayLink(nftMetadata.image)}</span
					>
				</p>
				<p>content alternative<span>{@html displayLink(nftMetadata.imageAlt)}</span></p>
				<p>content resaved<span>{@html displayLink(nftMetadata.imageResave)}</span></p>

				<hr />
				<p>
					{#if currentBatchId == ZERO_BYTES32}
						<button class="btn btn-topup" on:click={newBatch}>
							Buy batch
							{#if buying}
								<i class="fa-solid fa-spinner fa-spin-pulse" />
							{/if}
						</button>
					{:else}
						currentBatchId <span>{currentBatchId}</span>
					{/if}
				</p>
				<hr />
				<p>
					BZZ Chaind
					<span>{@html displayExplorer($bzzChainId)}</span>
				</p>
				<p>
					BzzToken
					<span>{@html displayExplorerField($bzzChainId, 'BzzToken')}</span>
				</p>
				<p>
					PriceOracle
					<span>{@html displayExplorerField($bzzChainId, 'PriceOracle')}</span>
				</p>
				<p>
					ERC6551Registry
					<span>{@html displayExplorerField($bzzChainId, 'ERC6551Registry')}</span>
				</p>
				<p>
					PostageStamp
					<span>{@html displayExplorerField($bzzChainId, 'PostageStamp')}</span>
				</p>
				<p>
					AutoSwarmAccount
					<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmAccount')}</span>
				</p>
				<p>
					AutoSwarmMarket
					<span>{@html displayExplorerField($bzzChainId, 'AutoSwarmMarket')}</span>
				</p>
				<p>
					Wallet - {displayBalance(walletBalance, 16, 4)} Bzz
					<span>{@html displayExplorerAddress($bzzChainId, walletAddress)}</span>
				</p>
				<p>
					TBA - {displayBalance(tbaBalance, 16, 4)} Bzz
					<span>{@html displayExplorerAddress($bzzChainId, tbaAddress)}</span>
				</p>
				<hr />
				<p>
					NFT Chaind
					<span>{@html displayExplorer(nftChainId)}</span>
				</p>
				<p>
					NFT Collection
					<span>{@html displayExplorerAddress(nftChainId, nftCollection)}</span>
				</p>
				<p>
					NFT TokenId
					<span>{@html displayExplorerAddress(nftChainId, nftCollection)}</span>
				</p>
			</div>
		{/if}
	</section>
{/if}

<style>
	#debug {
		width: 1100px;
		display: block;
		text-align: left;
	}
	#debug p span {
		float: right;
	}
</style>
