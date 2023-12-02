<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { onMount } from 'svelte';

	import type { NftMetadata, NftMetadataAutoSwarm } from '$lib/ts/constants/types';
	import {
		IMAGE_JPEG,
		METADATA_JSON,
		UNDEFINED_DATA,
		ZERO_BYTES32
	} from '$lib/ts/constants/constants';
	import { utilsError } from '$lib/ts/common/utils';
	import { callIsContract } from '$lib/ts/call/call';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { callTbaBzzHash, callTbaBzzSize, callTbaStampId } from '$lib/ts/call/callTba';
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
		displayLink,
		displaySize,
		displaySizeBytes
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
	let tbaBzzSize: bigint | undefined;
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
			tbaBzzSize = await callTbaBzzSize(bzzChainId, tbaAddress);
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
		<hr />
		<p>
			NFT - Chain Id / Collection Address / Token Id
			<span>
				{@html displayExplorer(nftChainId)} /
				{@html displayExplorerAddress(nftChainId, nftCollection)} /
				{@html displayExplorerNft(nftChainId, nftCollection, nftTokenId)}
			</span>
		</p>
		<hr />
		<p>
			NFT - Metadata URI / URL ({displaySizeBytes(
				nftMetadata.autoSwarm.tbaTokenUriSize || tokenUriSize
			)})
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
			NFT - Image URI / URL ({displaySizeBytes(nftMetadata.autoSwarm.tbaImageSize || imageSize)})
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
			Swarm - NFT Hash <span>{displayBzzURI(nftMetadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span>
		</p>
		<p>
			Swarm - NFT Size <span
				>{displaySizeBytes(nftMetadata.autoSwarm.bzzSize) || UNDEFINED_DATA}</span
			>
		</p>
		<p>
			Swarm - NFT Metadata Path
			<span>{@html displayBzzURI(nftMetadata.autoSwarm.bzzHash, METADATA_JSON)}</span>
		</p>
		<p>
			Swarm - NFT Image Path
			<span>{@html displayBzzURI(nftMetadata.autoSwarm.bzzHash, IMAGE_JPEG)}</span>
		</p>
		<hr />
		<p>
			TBA - Deployed? / Chain Id
			<span>
				{#if !tbaDeployed}Not{/if} deployed /
				{@html displayExplorer(bzzChainId)}
			</span>
		</p>
		<p>
			TBA - Bzz Balance / Address
			<span>
				{displayBalance(tbaBalance, 16, 4)} Bzz /
				{@html displayExplorerAddress(bzzChainId, tbaAddress)}
			</span>
		</p>
		<p>
			TBA - Bzz Hash <span>{tbaBzzHash || UNDEFINED_DATA}</span>
		</p>
		<p>
			TBA - Bzz Size <span>{tbaBzzSize || UNDEFINED_DATA}</span>
		</p>
		<p>
			TBA - Metadata URL
			<span>{@html displayBzzURL(tbaBzzHash, METADATA_JSON)}</span>
		</p>
		<p>
			TBA - Image URL
			<span> {@html displayBzzURL(tbaBzzHash, IMAGE_JPEG)}</span>
		</p>
		<p>
			TBA - Stamp Id <span>{tbaStampId || UNDEFINED_DATA}</span>
		</p>
		<p>
			TBA - Batch Id <span>{ZERO_BYTES32}</span>
		</p>
		<hr />
		<p>
			Wallet - Chain Id
			<span>
				{@html displayExplorer(walletChainId)}
			</span>
		</p>
		<p>
			Wallet Account - Bzz Balance / Address
			<span>
				{displayBalance(walletBalance, 16, 4)} Bzz /
				{@html displayExplorerAddress(bzzChainId, walletAddress)}
			</span>
		</p>
		<hr />
	</div>
{/if}

<style>
	#debug {
		width: 1000px;
		display: block;
		text-align: left;
	}
	#debug p span {
		float: right;
	}
</style>
