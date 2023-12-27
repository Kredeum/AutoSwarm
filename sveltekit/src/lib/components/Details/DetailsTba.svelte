<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { BeeMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
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

	///////////////////////////// Details TBA ///////////////////////////////////////
	// <DetailsTba  {tbaMetadata} />
	///////////////////////////// Details /////////////////////////////////////////////////
	export let tbaMetadata: TbaMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	TBA | Balance / ChainId / Address
	<span>
		{#if !tbaMetadata.tbaDeployed}Not{/if} deployed /
		{displayBalance(tbaMetadata.tbaBalance, 16, 4)} BZZ /
		{@html displayExplorer($bzzChainId)} /
		{@html displayExplorerAddress($bzzChainId, tbaMetadata.tbaAddress)}
	</span>
</p>
<p>
	TBA | Size / One Year Price
	<span>
		{displaySizeBytes(tbaMetadata.tbaSwarmSize)} /
		{displaySize(tbaMetadata.tbaSwarmSize)} /
		{displayBalance(tbaMetadata.tbaPrice, 16, 2) || UNDEFINED_DATA} BZZ
	</span>
</p>
<p>
	TBA | Hash <span>{@html displayBzzURI(tbaMetadata.tbaSwarmHash) || UNDEFINED_DATA}</span>
</p>

<p>
	TBA | Metadata URL
	<span>{@html displayBzzURL(tbaMetadata.tbaSwarmHash, 'metadata.json')}</span>
</p>
<p>
	TBA | Image URL
	<span> {@html displayBzzURL(tbaMetadata.tbaSwarmHash, tbaMetadata.tbaImageName)}</span>
</p>
<p>
	TBA | Stamp Id <span>{tbaMetadata.tbaStampId || UNDEFINED_DATA}</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
