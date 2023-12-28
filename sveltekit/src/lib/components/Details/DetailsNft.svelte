<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { SwarmMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { callMarketCurrentBatchId } from '$lib/ts/call/callMarket';

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
	import DetailsWallet from './DetailsWallet.svelte';
	import DetailsPostage from './DetailsPostage.svelte';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import DetailsTba from './DetailsTba.svelte';
	import DetailsBee from './DetailsBee.svelte';

	///////////////////////////// Details Nft ///////////////////////////////////////
	// <DetailsNft {nftMetadata}   />
	export let nftMetadata: NftMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	NFT | Chain Id / Collection Address / Token Id
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
<p>
	NFT | Metadata URI / URL
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
	NFT | Image URI / URL
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
<p>
	NFT | Size / One Year Price
	<span>
		{displaySizeBytes(nftMetadata.nftSize)} /
		{displaySize(nftMetadata.nftSize)} /
		{displayBalance(nftMetadata.nftPrice, 16, 2) || UNDEFINED_DATA} BZZ
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
	p.shift {
		margin-left: 50px;
	}
</style>
