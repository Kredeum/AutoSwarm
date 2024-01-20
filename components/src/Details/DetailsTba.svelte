<script lang="ts">
	import type { TbaMetadata } from '@autoswarm/common/src/constants/types';
	import { UNDEFINED_BYTES32, UNDEFINED_DATA } from '@autoswarm/common/src/constants/constants';

	import {
		displayBalance,
		displayBzzURI,
		displayBzzURL,
		displayDuration,
		displaySize,
		displaySizeBytes
	} from '@autoswarm/common/src/display/display';

	import DetailsAddress from './DetailsAddress.svelte';

	///////////////////////////// Details TBA ///////////////////////////////////////
	// <DetailsTba  {tbaMetadata} />
	///////////////////////////// Details /////////////////////////////////////////////////
	export let tbaMetadata: TbaMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<DetailsAddress address={tbaMetadata.tbaAddress} label="TBA" />

<p>
	TBA | Deployed? / Tba TTL + Stamp TTL = TTL
	<span>
		{#if !tbaMetadata.tbaDeployed}Not{/if} deployed /
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
