<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { onMount } from 'svelte';

	import type { NftMetadata, NftMetadataAutoSwarm } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';
	import { fetchAltUrl } from '$lib/ts/fetch/fetchAlt';
	import { utilsError } from '$lib/ts/common/utils';
	import { callIsContract } from '$lib/ts/call/call';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { callTbaBzzHash, callTbaStampId } from '$lib/ts/call/callTba';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';
	import { callRegistryAccount } from '$lib/ts/call/callRegistry';
	import { sendWalletAddress, sendWalletChainId } from '$lib/ts/send/send';
	import {
		displayBalance,
		displayBzzURI,
		displayBzzURL,
		displayExplorer,
		displayExplorerAddress,
		displayExplorerNft,
		displayLink
	} from '$lib/ts/display/display';

	///////////////////////////// Debug Component ///////////////////////////////////////
	// <Debug {bzzChainId} {nftChainId} {nftCollection} {nftTokenId} {nftMetadata} />
	///////////////////////////// Debug /////////////////////////////////////////////////
	// Debug component : display info on NFT, TBA and Swarm hashes
	/////////////////////////////////////////////////////////////////////////////////////
	export let bzzChainId: number;
	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	export let nftMetadata: NftMetadata;
	/////////////////////////////////////////////////////////////////////////////////////

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;
	let walletChainId: number | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;

	// TBA
	let tbaAddress: Address | undefined;
	let tbaBalance: bigint | undefined;
	let tbaBzzHash: Hex | undefined;
	let tbaStampId: Hex | undefined;

	// State
	let tbaDeployed = false;

	$: bzzChainId > 0 && nftChainId > 0 && nftCollection && nftTokenId >= 0 && refresh();
	const refresh = async () => {
		console.info('<NftDebug refresh  IN', bzzChainId, nftChainId, nftCollection, nftTokenId);
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance(bzzChainId, walletAddress);
			walletChainId = await sendWalletChainId();

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId(bzzChainId);

			// TBA
			tbaAddress = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);
			tbaBalance = await callBzzBalance(bzzChainId, tbaAddress);
			tbaBzzHash = await callTbaBzzHash(bzzChainId, tbaAddress);
			tbaStampId = await callTbaStampId(bzzChainId, tbaAddress);

			// STATE
			tbaDeployed = await callIsContract(bzzChainId, tbaAddress as Address);
		} catch (e) {
			utilsError('<Debug refresh', e);
		}
		console.info('<NftDebug refresh OUT');
	};
</script>

<div id="debug">
	{#if nftMetadata.autoSwarm}
		<p>
			NFT Chain Id / Collection Address / Token Id
			<span>
				{@html displayExplorer(nftChainId)} /
				{@html displayExplorerAddress(nftChainId, nftCollection)} /
				{@html displayExplorerNft(nftChainId, nftCollection, nftTokenId)}
			</span>
		</p>
		<hr />
		<p>
			NFT Metadata URI / URL
			<span>
				{@html displayLink(nftMetadata.autoSwarm.nftTokenUri)}
			</span>
		</p>
		<p>
			&nbsp;
			<span>
				{@html displayLink(nftMetadata.autoSwarm.nftTokenUriAlt)}
			</span>
		</p>
		<p>
			NFT Image URI / URL
			<span>
				{@html displayLink(nftMetadata.autoSwarm.nftImage)}
			</span>
		</p>
		<p>
			&nbsp;
			<span>
				{@html displayLink(nftMetadata.autoSwarm.nftImageAlt)}
			</span>
		</p>
		<hr />
		<p>
			NFT Swarm Bzz <span>{displayBzzURI(nftMetadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span>
		</p>
	{/if}
	<hr />
	<p>
		TBA Deployed? / Bzz Balance / Chain Id / Address
		<span>
			{#if !tbaDeployed}Not{/if} deployed /
			{displayBalance(tbaBalance, 16, 4)} Bzz /
			{@html displayExplorer(bzzChainId)} /
			{@html displayExplorerAddress(bzzChainId, tbaAddress)}
		</span>
	</p>
	<p>
		TBA Bzz URI <span>{displayBzzURI(tbaBzzHash) || UNDEFINED_DATA}</span>
	</p>
	<p>
		TBA Metadata URL <span> {@html displayBzzURL(tbaBzzHash, 'metadata.json')}</span>
	</p>
	<p>
		TBA Image URL <span> {@html displayBzzURL(tbaBzzHash, 'image')}</span>
	</p>
	<p>
		TBA Stamp Id <span>{tbaStampId || UNDEFINED_DATA}</span>
	</p>
	<hr />

	<p>
		Wallet Bzz Balance / Chain Id / Address
		<span>
			{displayBalance(walletBalance, 16, 4)} Bzz /
			{@html displayExplorer(walletChainId)} /
			{@html displayExplorerAddress(bzzChainId, walletAddress)}
		</span>
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
