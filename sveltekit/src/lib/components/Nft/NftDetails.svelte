<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { NftMetadata } from '$lib/ts/constants/types';
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
	// <Details {bzzChainId}   {metadata} />
	///////////////////////////// Details /////////////////////////////////////////////////
	// Details component : display info on NFT, TBA and Swarm hashes
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
		console.info('<NftDetails refresh  IN', bzzChainId, metadata);
		try {
			// Wallet
			walletAddress = await sendWalletAddress();
			walletBalance = await callBzzBalance(bzzChainId, walletAddress);
			walletChainId = await sendWalletChainId();

			// AutoSwarmMarket
			currentBatchId = await callMarketCurrentBatchId(bzzChainId);
			currentPrice = await callPostageLastPrice(bzzChainId);
		} catch (e) {
			alertError('<Details refresh', e);
		}
		console.info('<NftDetails refresh OUT');
	};
</script>

{#if metadata?.autoSwarm}
	<div id="details">
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
			NFT - Total Estimated Size / One Year Price
			<span>
				{displaySizeBytes(metadata.autoSwarm.nftSizeEstimation)} /
				{displaySize(metadata.autoSwarm.nftSizeEstimation)} /
				{displayBalance(metadata.autoSwarm.nftPriceEstimation, 16, 2) || UNDEFINED_DATA} BZZ
			</span>
		</p>
		<hr />
		<p>
			Swarm - Size / One Year Price
			<span>
				{displaySizeBytes(metadata.autoSwarm.bzzSize)} /
				{displaySize(metadata.autoSwarm.bzzSize)} /
				{displayBalance(metadata.autoSwarm.bzzPrice, 16, 2) || UNDEFINED_DATA} BZZ
			</span>
		</p>
		<p>
			Swarm - Hash <span>{@html displayBzzURI(metadata.autoSwarm.bzzHash) || UNDEFINED_DATA}</span>
		</p>
		<p>
			Swarm - Metadata Path
			<span>{@html displayBzzURI(metadata.autoSwarm.bzzHash, "metadata.json")}</span>
		</p>
		<p>
			Swarm - Image Path
			<span>{@html displayBzzURI(metadata.autoSwarm.bzzHash, metadata.autoSwarm.bzzImageName)}</span
			>
		</p>
		<hr />
		<p>
			TBA - Balance / ChainId / Address
			<span>
				{#if !metadata.autoSwarm.tbaDeployed}Not{/if} deployed /
				{displayBalance(metadata.autoSwarm.tbaBalance, 16, 4)} BZZ /
				{@html displayExplorer(bzzChainId)} /
				{@html displayExplorerAddress(bzzChainId, metadata.autoSwarm.tbaAddress)}
			</span>
		</p>
		<p>
			TBA - Size / One Year Price
			<span>
				{displaySizeBytes(metadata.autoSwarm.tbaSize)} /
				{displaySize(metadata.autoSwarm.tbaSize)} /
				{displayBalance(metadata.autoSwarm.tbaPrice, 16, 2) || UNDEFINED_DATA} BZZ
			</span>
		</p>
		<p>
			TBA - Hash <span>{metadata.autoSwarm.tbaHash || UNDEFINED_DATA}</span>
		</p>

		<p>
			TBA - Metadata URL
			<span>{@html displayBzzURL(metadata.autoSwarm.tbaHash, "metadata.json")}</span>
		</p>
		<p>
			TBA - Image URL
			<span>
				{@html displayBzzURL(metadata.autoSwarm.bzzHash, metadata.autoSwarm.bzzImageName)}</span
			>
		</p>
		<p>
			TBA - Stamp Id <span>{metadata.autoSwarm.tbaStampId || UNDEFINED_DATA}</span>
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
