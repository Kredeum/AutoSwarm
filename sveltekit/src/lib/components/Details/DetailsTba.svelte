<script lang="ts">
	import type { Address, Hex } from 'viem';

	import type { SwarmMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import {
		ONE_DAY,
		ONE_YEAR,
		STAMP_PRICE,
		UNDEFINED_BYTES32,
		UNDEFINED_DATA,
		ZERO_BYTES32
	} from '$lib/ts/constants/constants';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import {
		callMarketCurrentBatchId,
		callMarketGetStampRemainingBalance
	} from '$lib/ts/call/callMarket';

	import {
		displayBalance,
		displayBzzURI,
		displayBzzURL,
		displayDuration,
		displayLink,
		displaySize,
		displaySizeBytes,
		displayTtl
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
	import { onMount } from 'svelte';
	import { utilsIsNullBytes32, utilsDivUp } from '$lib/ts/common/utils';

	///////////////////////////// Details TBA ///////////////////////////////////////
	// <DetailsTba  {tbaMetadata} />
	///////////////////////////// Details /////////////////////////////////////////////////
	export let tbaMetadata: TbaMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	TBA | Deployed? / ChainId / Address
	<span>
		{#if !tbaMetadata.tbaDeployed}Not{/if} deployed /
		{@html displayExplorer($bzzChainId)} /
		{@html displayExplorerAddress($bzzChainId, tbaMetadata.tbaAddress)}
	</span>
</p>
<p>
	TBA | Balance / Tba TTL + Stamp TTL = TTL
	<span>
		{displayBalance(tbaMetadata.tbaBalance, 16, 4)} BZZ /
		{displayDuration(tbaMetadata.tbaBzzDuration)} +
		{displayDuration(tbaMetadata.tbaStampDuration)}
		{#if tbaMetadata.tbaBzzDuration && tbaMetadata.tbaStampDuration}={:else}>={/if}
		{displayDuration(tbaMetadata.tbaDuration)}
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
	TBA | Stamp Id <span>{tbaMetadata.tbaStampId || UNDEFINED_BYTES32}</span>
</p>
<p>
	TBA | Batch Id <span>{tbaMetadata.tbaBatchId || UNDEFINED_BYTES32}</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
