<script lang="ts">
	import type { BeeMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';

	import { displayBzzURI } from '$lib/ts/display/display';

	///////////////////////////// Details bee ///////////////////////////////////////
	// <DetailsBee {beeMetadata}   />
	/////////////////////////////////////////////////////////////////////////////////////
	export let beeMetadata: BeeMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	Swarm | Hash <span>{@html displayBzzURI(beeMetadata.beeHash) || UNDEFINED_DATA}</span>
</p>
<p>
	Swarm | Metadata Path
	<span>{@html displayBzzURI(beeMetadata.beeHash, 'metadata.json')}</span>
</p>
<p>
	Swarm | Image Path
	<!-- <span>{@html displayBzzURI(beeMetadata.beeHash, beeMetadata.beeImageName)}</span> -->
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
