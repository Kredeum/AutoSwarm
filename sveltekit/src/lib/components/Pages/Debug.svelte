<script lang="ts">
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { ZERO_BYTES32, type NftMetadata, BATCH_UNIT_PRICE } from '$lib/ts/constants/constants';
	import { jsonGetField } from '$lib/ts/constants/json';
	import {
		displayBalance,
		displayExplorer,
		displayExplorerAddress,
		displayExplorerField,
		displayExplorerNft,
		displayLink
	} from '$lib/ts/display/display';
	import { sendBzzTransfer } from '$lib/ts/send/sendBzz';
	import { sendMarketNewBatch } from '$lib/ts/send/sendMarket';
	import { sendWalletAddress } from '$lib/ts/send/send';
	import { utilsError } from '$lib/ts/swarm/utils';
	import type { Address, Hex } from 'viem';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';
	import { callRegistryAccount } from '$lib/ts/call/callRegistry';
	import { onMount } from 'svelte';
	import { callIsContract } from '$lib/ts/call/call';

	export let bzzChainId: number;
	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	export let nftMetadata: NftMetadata;

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;

	// TBA
	let tbaAddress: Address | undefined;
	let tbaBalance: bigint | undefined;

	// State
	let tbaDeployed = false;
	let monthlyCroning = false;
	let dailyCroning = false;

	const reset = () => {
		tbaAddress = undefined;
		tbaBalance = undefined;
		currentBatchId = undefined;
	};

	const refresh = async () => {
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance(bzzChainId, walletAddress);

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId(bzzChainId);

			// TBA
			tbaAddress = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
			tbaBalance = await callBzzBalance(bzzChainId, tbaAddress);

			// STATE
			tbaDeployed = await callIsContract(bzzChainId, tbaAddress as Address);
		} catch (e) {
			utilsError('<Monitor/> refresh', e);
		}
	};

	const dailyCron = async () => {
		console.info('DailyCron');

		try {
			if (dailyCroning) throw Error('Already running!');
			dailyCroning = true;
		} catch (e) {
			utilsError('<Monitor/> Daily Cron:', e);
		}

		dailyCroning = false;
	};

	const monthlyCron = async () => {
		console.info('MonthlyCron');

		try {
			if (monthlyCroning) throw Error('Already running!');
			monthlyCroning = true;

			const autoSwarmMarket = jsonGetField(bzzChainId, 'AutoSwarmMarket') as Address;
			await sendBzzTransfer(bzzChainId, autoSwarmMarket, BATCH_UNIT_PRICE);
			await sendMarketNewBatch(bzzChainId);
		} catch (e) {
			utilsError('<Monitor/> Monthly Cron:', e);
		}

		monthlyCroning = false;
	};

	onMount(refresh);
</script>

<div id="debug">
	{#if nftMetadata}
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
	{/if}
	<hr />
	<p>
		Wallet - {displayBalance(walletBalance, 16, 4)} Bzz
		<span>{@html displayExplorerAddress(bzzChainId, walletAddress)}</span>
	</p>
	<p>
		TBA - {displayBalance(tbaBalance, 16, 4)} Bzz - {#if !tbaDeployed}Not{/if} deployed
		<span>{@html displayExplorerAddress(bzzChainId, tbaAddress)}</span>
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
		<span>{@html displayExplorerNft(nftChainId, nftCollection, nftTokenId)}</span>
	</p>
</div>

<style>
	#debug {
		width: 1200px;
		display: block;
		text-align: left;
	}
	#debug p span {
		float: right;
	}
</style>
