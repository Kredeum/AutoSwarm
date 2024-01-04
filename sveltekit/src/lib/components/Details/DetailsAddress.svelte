<script lang="ts">
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { displayBalance } from '$lib/ts/display/display';
	import { displayExplorer, displayExplorerAddress } from '$lib/ts/display/displayExplorer';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	import type { Address } from 'viem';

	///////////////////////////// Details Market ///////////////////////////////////////
	// <DetailsAddress address chainId label />
	/////////////////////////////////////////////////////////////////////////////////////
	export let address: Address | undefined = undefined;
	export let chainId: number | undefined = $bzzChainId;
	export let label: string = 'Address';
	/////////////////////////////////////////////////////////////////////////////////////

	let balance: bigint | undefined;

	$: address && refresh();

	const refresh = async () => {
		balance = await callBzzBalance($bzzChainId, address);
	};
</script>

<p>
	{label} | {#if balance}Balance /{/if} Chain Id / Address
	<span>
		{#if balance}{displayBalance(balance, 16, 4)} BZZ /{/if}
		{@html displayExplorer(chainId)} /
		{@html displayExplorerAddress(chainId, address)}
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
