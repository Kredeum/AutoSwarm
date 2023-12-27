<script lang="ts">
	import type { Address } from 'viem';
	import { callBzzBalance } from '$lib/ts/call/callBzz';
	import { sendWalletAddress, sendWalletChainId } from '$lib/ts/send/send';
	import { displayBalance } from '$lib/ts/display/display';
	import { displayExplorer, displayExplorerAddress } from '$lib/ts/display/displayExplorer';
	import { onMount } from 'svelte';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	///////////////////////////// Details Wallet ///////////////////////////////////////
	// <DetailsWallet />
	/////////////////////////////////////////////////////////////////////////////////////
	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;
	let walletChainId: number | undefined;

	const refresh = async () => {
		walletAddress = await sendWalletAddress();
		walletBalance = await callBzzBalance($bzzChainId, walletAddress);
		walletChainId = await sendWalletChainId();
	};
	onMount(refresh);
</script>

<p>
	Wallet | Balance / Chain Id / Address
	<span>
		{displayBalance(walletBalance, 16, 4)} BZZ /
		{@html displayExplorer(walletChainId)} /
		{@html displayExplorerAddress($bzzChainId, walletAddress)}
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
