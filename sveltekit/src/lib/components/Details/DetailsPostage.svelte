<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { sendWalletAddress, sendWalletChainId } from '$lib/ts/send/send';
	import { displayBalance } from '$lib/ts/display/display';
	import { displayExplorer, displayExplorerAddress } from '$lib/ts/display/displayExplorer';
	import { onMount } from 'svelte';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	import { callPostageLastPrice } from '$lib/ts/call/callPostage';
	import { BATCH_DEPTH, BATCH_TTL, UNDEFINED_DATA } from '$lib/ts/constants/constants';
	import { batchPrice } from '$lib/ts/swarm/batch';

	///////////////////////////// Details PostageStamp //////////////////////////////////
	// <DetailsPostage />
	/////////////////////////////////////////////////////////////////////////////////////
	let latestChunkPrice: bigint | undefined;
	let latestBatchPrice: bigint | undefined;
	const refresh = async () => {
		latestChunkPrice = await callPostageLastPrice($bzzChainId);
		latestBatchPrice = await batchPrice($bzzChainId, BATCH_DEPTH, BATCH_TTL, latestChunkPrice);
	};
	onMount(refresh);
</script>

<p>
	Postage | Chunk Last Price / Batch Last Price
	<span>
		{displayBalance(latestChunkPrice, 0, 0)} PLUR per block /
		{displayBalance(latestBatchPrice, 16, 4)} Bzz
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
