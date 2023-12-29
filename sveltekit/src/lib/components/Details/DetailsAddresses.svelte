<script lang="ts">
	import { displayExplorer, displayExplorerField } from '$lib/ts/display/displayExplorer';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	///////////////////////////// Details Addresses ///////////////////////////////////////
	// <DetailsAddresses />
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	Addresses | BZZ Chain Id / BZZ Token address
	<span>
		{@html displayExplorer($bzzChainId)} / {@html displayExplorerField($bzzChainId, 'BzzToken')}
	</span>
</p>
<p>
	Addresses | AutoSwarmAccount<span
		>{@html displayExplorerField($bzzChainId, 'AutoSwarmAccount')}</span
	>
</p>
<p>
	Addresses | AutoSwarmMarket<span
		>{@html displayExplorerField($bzzChainId, 'AutoSwarmMarket')}</span
	>
</p>
<p>
	Addresses | ERC6551 Registry<span
		>{@html displayExplorerField($bzzChainId, 'ERC6551Registry')}</span
	>
</p>
<p>
	Addresses | PostageStamp<span>{@html displayExplorerField($bzzChainId, 'PostageStamp')}</span>
</p>
<p>Addresses | PriceOracle<span>{@html displayExplorerField($bzzChainId, 'PriceOracle')}</span></p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
