<script lang="ts">
	import { bzzChainsId } from '$lib/ts/constants/chains';

	import NetworkSimple from './NetworkSimple.svelte';

	/////////////////////////////////////////////////
	// <NetworkListSelectSimple bind:{chainId}  />
	// Select Network via a list box
	/////////////////////////////////////////////////
	export let chainId: number;
	// $: console.info('NetworkListSelectSimple chainId CHANGE', chainId);

	interface SwitchEventTarget extends EventTarget {
		value: number;
	}
	const _switchChainEvt = (evt: Event) =>
		(chainId = Number((evt.target as SwitchEventTarget).value));
</script>

<select on:change={_switchChainEvt}>
	{#each bzzChainsId as bzzChainId}
		<option value={bzzChainId} selected={bzzChainId == chainId}>
			<NetworkSimple chainId={bzzChainId} />
		</option>
	{/each}
</select>
