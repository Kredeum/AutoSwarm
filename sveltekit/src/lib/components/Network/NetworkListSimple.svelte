<script lang="ts">
	import { chainsId } from '$lib/ts/chains';

	import NetworkSimple from './NetworkSimple.svelte';

	/////////////////////////////////////////////////
	// <NetworksListSimple networks />
	/////////////////////////////////////////////////
</script>

{#each chainsId as chainId}
	<NetworkSimple {chainId} />
{/each}
