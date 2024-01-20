<script lang="ts">
	import type { Address, Hex } from 'viem';
	import { callBzzBalance } from '@autoswarm/common/src/call/callBzz';
	import { sendWalletAddress, sendWalletChainId } from '@autoswarm/common/src/send/send';
	import { displayBalance } from '@autoswarm/common/src/display/display';
	import {
		displayExplorer,
		displayExplorerAddress
	} from '@autoswarm/common/src/display/displayExplorer';
	import { onMount } from 'svelte';
	import { bzzChainId } from '@autoswarm/common/src/swarm/bzz';

	import { callPostageLastPrice } from '@autoswarm/common/src/call/callPostage';
	import {
		BATCH_DEPTH,
		BATCH_TTL,
		UNDEFINED_DATA
	} from '@autoswarm/common/src/constants/constants';
	import { batchPrice } from '@autoswarm/common/src/swarm/batch';

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
