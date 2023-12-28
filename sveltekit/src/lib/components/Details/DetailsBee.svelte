<script lang="ts">
	import type { SwarmMetadata, Metadata, NftMetadata, TbaMetadata } from '$lib/ts/constants/types';
	import { UNDEFINED_DATA } from '$lib/ts/constants/constants';

	import { displayBzzURI } from '$lib/ts/display/display';

	///////////////////////////// Details bee ///////////////////////////////////////
	// <DetailsBee {beeMetadata}   />
	/////////////////////////////////////////////////////////////////////////////////////
	export let beeMetadata: SwarmMetadata;
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	Swarm | Hash <span>{@html displayBzzURI(beeMetadata.swarmHash) || UNDEFINED_DATA}</span>
</p>
<p>
	Swarm | Metadata Path
	<span>{@html displayBzzURI(beeMetadata.swarmHash, 'metadata.json')}</span>
</p>
<p>
	Swarm | Image Path
	<span>{@html displayBzzURI(beeMetadata.swarmHash, beeMetadata.swarmImageName)}</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
