<script lang="ts">
	import { chainGet } from '$lib/ts/chains';
	export let chainId: number;

	const chain = chainGet(chainId);

	/////////////////////////////////////////////////
	// <NetworkSimple chainId />
	/////////////////////////////////////////////////
</script>

{#if chain}
	{chain.name} ({chain.id})
{:else}
	Bad Chain {chainId}
{/if}
