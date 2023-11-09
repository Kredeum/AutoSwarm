<script lang="ts">
	import { chainsId } from '$lib/ts/chains';

	import NetworkSimple from './NetworkSimple.svelte';

	/////////////////////////////////////////////////
	// <NetworkListSelectSimple bind:{chainId}  />
	// Select Network via a list box
	/////////////////////////////////////////////////
	export let chainId: number;
	$: console.log('NetworkListSelectSimple chainId CHANGE', chainId);

	interface SwitchEventTarget extends EventTarget {
		value: number;
	}
	const _switchChainEvt = (evt: Event) =>
		(chainId = Number((evt.target as SwitchEventTarget).value));
</script>

<select on:change={_switchChainEvt}>
	{#each chainsId as id}
		<option value={id} selected={id == chainId}>
			<NetworkSimple chainId={id} />
		</option>
	{/each}
</select>
