<script lang="ts">
	import { callMarketCurrentSwarmNode } from '$lib/ts/call/callMarket';
	import { addressesGetField } from '$lib/ts/common/addresses';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { onMount } from 'svelte';
	import type { Address, Hex } from 'viem';
	import DetailsAddress from './DetailsAddress.svelte';

	///////////////////////////// Details Market ///////////////////////////////////////
	// <DetailsMarket fields />
	/////////////////////////////////////////////////////////////////////////////////////
	export let fields: string | undefined = undefined;
	/////////////////////////////////////////////////////////////////////////////////////

	let marketAddress: Address | undefined;
	let currentSwarmNode: Address | undefined;

	const refresh = async () => {
		marketAddress = addressesGetField($bzzChainId, 'AutoSwarmMarket');
		currentSwarmNode = await callMarketCurrentSwarmNode($bzzChainId);
	};

	const isField = (field: string): boolean => !fields || fields.includes(field);

	onMount(async () => {
		await refresh();
	});
</script>

{#if isField('address')}
	<DetailsAddress address={marketAddress} label="Market | Contract" />
{/if}

{#if isField('owner')}
	<DetailsAddress address={currentSwarmNode} label="Market | SwarmNode" />
{/if}
