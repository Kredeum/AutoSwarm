<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { NftMetadata } from '$lib/ts/constants/types';
	import {
		IMAGE_JPEG,
		METADATA_JSON,
		UNDEFINED_DATA,
		ZERO_BYTES32
	} from '$lib/ts/constants/constants';
	import { utilsError } from '$lib/ts/common/utils';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';

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
	import { callPostageLastPrice } from '$lib/ts/call/callPostage';

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
			utilsError('<Debug refresh', e);
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
			{displaySizeBytes(metadata.autoSwarm.nftTokenUriSize)}
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
			{displaySizeBytes(metadata.autoSwarm.nftImageSize)}
			<span>
				{@html displayLink(metadata.autoSwarm.nftImageAlt)}
			</span>
		</p>
		<hr />
		<p>
			Swarm - NFT Hash <span
				>{@html displayBzzURI(metadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span
			>
		</p>
		<p>
			Swarm - NFT Size
			<span>
				{displaySizeBytes(metadata.autoSwarm.bzzSize) || UNDEFINED_DATA} /
				{displaySize(metadata.autoSwarm.bzzSize) || UNDEFINED_DATA}
			</span>
		</p>
		<p>
			Swarm - NFT One Year Price <span
				>{displayBalance(metadata.autoSwarm.bzzPrice, 16, 4) || UNDEFINED_DATA} Bzz</span
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
		<hr />
		<p>
			TBA - Deployed? / Chain Id
			<span>
				{#if !metadata.autoSwarm.tbaDeployed}Not{/if} deployed /
				{@html displayExplorer(bzzChainId)}
			</span>
		</p>
		<p>
			TBA - Bzz Balance / Address
			<span>
				{displayBalance(metadata.autoSwarm.tbaBalance, 16, 4)} Bzz /
				{@html displayExplorerAddress(bzzChainId, metadata?.autoSwarm?.tbaAddress)}
			</span>
		</p>
		<p>
			TBA - Bzz Hash <span>{metadata?.autoSwarm?.bzzHash || UNDEFINED_DATA}</span>
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
			Postage - Current Batch Id <span>{currentBatchId || UNDEFINED_DATA}</span>
		</p>
		<p>
			Postage - Current Price<span>{displayBalance(currentPrice, 0, 0)}</span>
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
		font-family: Monaco;
	}
	#debug p.shift {
		margin-left: 50px;
	}
</style>
