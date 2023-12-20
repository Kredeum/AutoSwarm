<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { BzzMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';

	import { sendWalletAddress, sendWalletChainId } from '$lib/ts/send/send';
	import {
		displayBalance,
		displayBzzURI,
		displayBzzURL,
		displayLink,
		displaySize,
		displaySizeBytes
	} from '$lib/ts/display/display';
	import { callPostageLastPrice } from '$lib/ts/call/callPostage';
	import {
		displayExplorer,
		displayExplorerAddress,
		displayExplorerNft
	} from '$lib/ts/display/displayExplorer';
	import { alertError } from '$lib/ts/stores/alertMessage';

	///////////////////////////// Details Component ///////////////////////////////////////
	// <Details {tbaChainId}   {metadata} />
	///////////////////////////// Details /////////////////////////////////////////////////
	// Details component : display info on NFT, TBA and Swarm hashes
	/////////////////////////////////////////////////////////////////////////////////////
	export let tbaChainId: number;
	export let metadata: Metadata;
	export let nftMetadata: NftMetadata;
	export let bzzMetadata: BzzMetadata;
	export let tbaMetadata: TbaMetadata;
	/////////////////////////////////////////////////////////////////////////////////////

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;
	let walletChainId: number | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;
	let currentPrice: bigint | undefined;

	$: tbaChainId > 0 && metadata && refresh();
	const refresh = async () => {
		console.info('<NftDetails refresh  IN', tbaChainId, metadata);
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance(tbaChainId, walletAddress);
			walletChainId = await sendWalletChainId();

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId(tbaChainId);
			currentPrice = await callPostageLastPrice(tbaChainId);
		} catch (e) {
			alertError('<Details refresh', e);
		}
		console.info('<NftDetails refresh OUT');
	};
</script>

<div id="details">
	<hr />
	<p>
		NFT - Chain Id / Collection Address / Token Id
		<span>
			{@html displayExplorer(nftMetadata.nftChainId)} /
			{@html displayExplorerAddress(nftMetadata.nftChainId, nftMetadata.nftCollection)} /
			{@html displayExplorerNft(
				nftMetadata.nftChainId,
				nftMetadata.nftCollection,
				nftMetadata.nftTokenId
			)}
		</span>
	</p>
	<hr />
	{#if nftMetadata.nftMetadataUri}
		<p>
			NFT - Metadata URI / URL
			<span>
				{@html displayLink(nftMetadata.nftMetadataUri)}
			</span>
		</p>
		<p class="shift">
			{displaySize(nftMetadata.nftMetadataSize)}
			<span>
				{@html displayLink(nftMetadata.nftMetadataUriAlt)}
			</span>
		</p>
		<p>
			NFT - Image URI / URL
			<span>
				{@html displayLink(nftMetadata.nftImageUri)}
			</span>
		</p>
		<p class="shift">
			{displaySize(nftMetadata.nftImageSize)}
			<span>
				{@html displayLink(nftMetadata.nftImageUriAlt)}
			</span>
		</p>
	{/if}
	<hr />
	<p>
		Swarm - Size / One Year Price
		<span>
			{displaySizeBytes(bzzMetadata.bzzSize)} /
			{displaySize(bzzMetadata.bzzSize)} /
			{displayBalance(bzzMetadata.bzzPrice, 16, 2) || UNDEFINED_DATA} BZZ
		</span>
	</p>
	<hr />
		<p>
			Swarm - Hash <span>{@html displayBzzURI(bzzMetadata.bzzHash) || UNDEFINED_DATA}</span>
		</p>
		<p>
			Swarm - Metadata Path
			<span>{@html displayBzzURI(bzzMetadata.bzzHash, 'metadata.json')}</span>
		</p>
		<p>
			Swarm - Image Path
			<span>{@html displayBzzURI(bzzMetadata.bzzHash, bzzMetadata.bzzImageName)}</span>
		</p>
	<hr />
	<p>
		TBA - Balance / ChainId / Address
		<span>
			{#if !tbaMetadata.tbaDeployed}Not{/if} deployed /
			{displayBalance(tbaMetadata.tbaBalance, 16, 4)} BZZ /
			{@html displayExplorer(tbaChainId)} /
			{@html displayExplorerAddress(tbaChainId, tbaMetadata.tbaAddress)}
		</span>
	</p>
	<hr />
		<p>
			TBA - Size / One Year Price
			<span>
				{displaySizeBytes(tbaMetadata.tbaSize)} /
				{displaySize(tbaMetadata.tbaSize)} /
				{displayBalance(tbaMetadata.tbaPrice, 16, 2) || UNDEFINED_DATA} BZZ
			</span>
		</p>
		<p>
			TBA - Hash <span>{tbaMetadata.tbaHash || UNDEFINED_DATA}</span>
		</p>

		<p>
			TBA - Metadata URL
			<span>{@html displayBzzURL(tbaMetadata.tbaHash, 'metadata.json')}</span>
		</p>
		<p>
			TBA - Image URL
			<span> {@html displayBzzURL(tbaMetadata.tbaHash, bzzMetadata.bzzImageName)}</span>
		</p>
		<p>
			TBA - Stamp Id <span>{tbaMetadata.tbaStampId || UNDEFINED_DATA}</span>
		</p>
	<hr />
	<p>
		Postage - Latest Price / Batch Id
		<span>
			{displayBalance(currentPrice, 0, 0)} PLUR /
			{currentBatchId || UNDEFINED_DATA}
		</span>
	</p>
	<hr />
		<p>
			Wallet - Balance / Chain Id / Address
			<span>
				{displayBalance(walletBalance, 16, 4)} BZZ /
				{@html displayExplorer(walletChainId)} /
				{@html displayExplorerAddress(tbaChainId, walletAddress)}
			</span>
		</p>
	<hr />
</div>

<style>
	#details {
		width: 1100px;
		display: block;
		text-align: left;
	}
	#details p span {
		float: right;
		font-family: Monaco;
	}
	#details p.shift {
		margin-left: 50px;
	}
</style>
