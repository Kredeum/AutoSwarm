<script lang="ts">
	import { bzzChainsId } from '@autoswarm/common/src/common/chains';

	import NetworkSimple from './NetworkSimple.svelte';

	/////////////////////////////////////////////////
	// <NetworksListSimple networks />
	/////////////////////////////////////////////////
</script>

{#each bzzChainsId as chainId}
	<NetworkSimple {chainId} />
{/each}
