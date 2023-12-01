<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { onMount } from 'svelte';

	import type { NftMetadata, NftMetadataAutoSwarm } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';
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
	import { fetchSize } from '$lib/ts/fetch/fetch';
	import { urlToUrlAlt } from '$lib/ts/common/url';

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

	let tokenUriSize: number | undefined;
	let imageSize: number | undefined;

	$: bzzChainId > 0 && nftChainId > 0 && nftCollection && nftTokenId >= 0 && refresh();
	const refresh = async () => {
		console.info('<NftDebug refresh  IN', bzzChainId, nftChainId, nftCollection, nftTokenId);
		try {
			// Sizes
			tokenUriSize = await fetchSize(urlToUrlAlt(nftMetadata.autoSwarm?.nftTokenUri));
			imageSize = await fetchSize(urlToUrlAlt(nftMetadata.autoSwarm?.nftImage));

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

{#if nftMetadata?.autoSwarm}
	<div id="debug">
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
			NFT Metadata URI / URL  ({nftMetadata.autoSwarm.tbaTokenUriSize ||
				tokenUriSize ||
				UNDEFINED_DATA} bytes)
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
			NFT Image URI / URL ({nftMetadata.autoSwarm.tbaImageSize || imageSize || UNDEFINED_DATA} bytes)
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
			NFT Swarm Hash <span>{displayBzzURI(nftMetadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span>
		</p>
		<p>
			NFT Metadata Swarm Path
			<span>{@html displayBzzURI(nftMetadata.autoSwarm.bzzHash, 'metadata.json')}</span>
		</p>
		<p>
			NFT Image Swarm Path
			<span>{@html displayBzzURI(nftMetadata.autoSwarm.bzzHash, 'image')}</span>
		</p>
		<hr />
		<p>
			Bzz Balance / TBA Deployed? / Chain Id / Address
			<span>
				{displayBalance(tbaBalance, 16, 4)} Bzz /
				{#if !tbaDeployed}Not{/if} deployed /
				{@html displayExplorer(bzzChainId)} /
				{@html displayExplorerAddress(bzzChainId, tbaAddress)}
			</span>
		</p>
		<p>
			TBA Bzz Hash <span>{tbaBzzHash || UNDEFINED_DATA}</span>
		</p>
		<p>
			TBA Metadata URL
			<span>{@html displayBzzURL(tbaBzzHash, 'metadata.json')}</span>
		</p>
		<p>
			TBA Image URL
			<span> {@html displayBzzURL(tbaBzzHash, 'image')}</span>
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
{/if}

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
