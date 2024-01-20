<script lang="ts">
	import type { Address } from 'viem';
	import { sendWalletAddress, sendWalletChainId } from '@autoswarm/common/src/send/send';
	import { onMount } from 'svelte';
	import DetailsAddress from './DetailsAddress.svelte';

	///////////////////////////// Details Wallet ///////////////////////////////////////
	// <DetailsWallet />
	/////////////////////////////////////////////////////////////////////////////////////
	let walletAddress: Address | undefined;
	let walletChainId: number | undefined;

	const refresh = async () => {
		walletAddress = await sendWalletAddress();
		walletChainId = await sendWalletChainId();
	};

	onMount(refresh);
</script>

<DetailsAddress address={walletAddress} chainId={walletChainId} label="Wallet" />
