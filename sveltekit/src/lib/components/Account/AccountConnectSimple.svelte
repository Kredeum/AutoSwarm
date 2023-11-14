<script lang="ts">
	import type { Address } from 'viem';
	import { onMount } from 'svelte';

	import { writeWalletAddress } from '$lib/ts/onchain/write';
	import AccountSimple from './AccountSimple.svelte';

	/////////////////////////////////////////////////
	// <AccountConnect bind:{account}  />
	// Get Signer from Metamask
	/////////////////////////////////////////////////
	export let account: Address | undefined = undefined;

	const getWalletAddress = async () => {
		account = await writeWalletAddress(undefined, true);
		console.log('AccountConnect account CHANGE', account);
	};

	onMount(() => {
		window.ethereum?.on('accountsChanged', getWalletAddress);
	});
</script>

{#if account}
	<AccountSimple {account} />
{:else}
	<button on:click={getWalletAddress}>Connect</button>
{/if}
