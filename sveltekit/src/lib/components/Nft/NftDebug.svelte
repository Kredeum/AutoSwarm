<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { NftMetadata } from '$lib/ts/constants/types';
	import {
		IMAGE_JPEG,
		METADATA_JSON,
		UNDEFINED_DATA,
	} from '$lib/ts/constants/constants';
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

	///////////////////////////// Debug Component ///////////////////////////////////////
	// <Debug {bzzChainId}   {metadata} />
	///////////////////////////// Debug /////////////////////////////////////////////////
	// Debug component : display info on NFT, TBA and Swarm hashes
	/////////////////////////////////////////////////////////////////////////////////////
	export let bzzChainId: number;
	export let metadata: NftMetadata;
	/////////////////////////////////////////////////////////////////////////////////////

	// Wallet
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;
	let walletChainId: number | undefined;

	// AutoSwarmMarket
	let currentBatchId: Hex | undefined;
	let currentPrice: bigint | undefined;

	$: autoSwarm = metadata?.autoSwarm;

	$: bzzChainId > 0 && metadata && refresh();
	const refresh = async () => {
		console.info('<NftDebug refresh  IN', bzzChainId, metadata);
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance(bzzChainId, walletAddress);
			walletChainId = await sendWalletChainId();

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId(bzzChainId);
			currentPrice = await callPostageLastPrice(bzzChainId);
		} catch (e) {
			alertError('<Debug refresh', e);
		}
		console.info('<NftDebug refresh OUT');
	};
</script>

{#if metadata?.autoSwarm}
	<div id="debug">
		<hr />
		<p>
			NFT - Chain Id / Collection Address / Token Id
			<span>
				{@html displayExplorer(autoSwarm?.nftChainId)} /
				{@html displayExplorerAddress(autoSwarm?.nftChainId, autoSwarm?.nftCollection)} /
				{@html displayExplorerNft(
					autoSwarm?.nftChainId,
					autoSwarm?.nftCollection,
					autoSwarm?.nftTokenId
				)}
			</span>
		</p>
		<hr />
		<p>
			NFT - Metadata URI / URL
			<span>
				{@html displayLink(metadata.autoSwarm.nftTokenUri)}
			</span>
		</p>
		<p class="shift">
			{displaySize(metadata.autoSwarm.nftTokenUriSize)}
			<span>
				{@html displayLink(metadata.autoSwarm.nftTokenUriAlt)}
			</span>
		</p>
		<p>
			NFT - Image URI / URL
			<span>
				{@html displayLink(metadata.autoSwarm.nftImage)}
			</span>
		</p>
		<p class="shift">
			{displaySize(metadata.autoSwarm.nftImageSize)}
			<span>
				{@html displayLink(metadata.autoSwarm.nftImageAlt)}
			</span>
		</p>
		<p>
			NFT - Total Estimated Size / Price
			<span>
				{displaySizeBytes(metadata.autoSwarm.nftSizeEstimation)} /
				{displaySize(metadata.autoSwarm.nftSizeEstimation)} /
				{displayBalance(metadata.autoSwarm.nftPriceEstimation, 16, 2) || UNDEFINED_DATA} BZZ
			</span>
		</p>
		<hr />
		<p>
			Swarm - NFT Size
			<span>
				{displaySizeBytes(metadata.autoSwarm.bzzSize)} /
				{displaySize(metadata.autoSwarm.bzzSize)}
			</span>
		</p>
		<p>
			Swarm - NFT Hash <span
				>{@html displayBzzURI(metadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span
			>
		</p>
		<p>
      Swarm - NFT Metadata Path
			<span>{@html displayBzzURI(metadata.autoSwarm.bzzHash, METADATA_JSON)}</span>
		</p>
		<p>
      Swarm - NFT Image Path
			<span>{@html displayBzzURI(metadata.autoSwarm.bzzHash, IMAGE_JPEG)}</span>
		</p>
    <p>
      Swarm - NFT One Year Price <span
        >{displayBalance(metadata.autoSwarm.bzzPrice, 16, 4) || UNDEFINED_DATA} BZZ</span
      >
    </p>
		<hr />
		<p>
			TBA - Balance / ChainId / Address
			<span>
        {#if !metadata.autoSwarm.tbaDeployed}Not{/if} deployed /
				{displayBalance(metadata.autoSwarm.tbaBalance, 16, 4)} BZZ /
				{@html displayExplorer(bzzChainId)} /
				{@html displayExplorerAddress(bzzChainId, metadata?.autoSwarm?.tbaAddress)}
			</span>
		</p>
		<p>
			TBA - Size
			<span>
				{metadata?.autoSwarm?.bzzHash || UNDEFINED_DATA}
			</span>
		</p>
		<p>
			TBA - BZZ Hash <span>{metadata?.autoSwarm?.bzzHash || UNDEFINED_DATA}</span>
		</p>

		<p>
			TBA - Metadata URL
			<span>{@html displayBzzURL(metadata.autoSwarm.bzzHash, METADATA_JSON)}</span>
		</p>
		<p>
			TBA - Image URL
			<span> {@html displayBzzURL(metadata.autoSwarm.bzzHash, IMAGE_JPEG)}</span>
		</p>
		<p>
			TBA - Stamp Id <span>{metadata.autoSwarm.bzzStampId || UNDEFINED_DATA}</span>
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
				{@html displayExplorerAddress(bzzChainId, walletAddress)}
			</span>
		</p>
		<hr />
	</div>
{/if}

<style>
	#debug {
		width: 1100px;
		display: block;
		text-align: left;
	}
	#debug p span {
		float: right;
		font-family: Monaco;
	}
	#debug p.shift {
		margin-left: 50px;
	}
</style>
