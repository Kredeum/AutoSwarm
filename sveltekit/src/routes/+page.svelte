<script lang="ts">
	import type { WalletClient, PublicClient, Address } from 'viem';
	import type { NftMetadata } from '$lib/types/types';

	import 'viem/window';
	import { createPublicClient, createWalletClient, custom } from 'viem';

	import { onMount } from 'svelte';

	let walletClient: WalletClient;
	let client: PublicClient;

	let account: string;
	let chainId: number;

	let nftMetadatas: NftMetadata;

	$: console.log('account switch', account);
	$: console.log('chainId switch', chainId);
	$: console.log('NFT metadatas', nftMetadatas);

	onMount(async () => {
		if (typeof window.ethereum !== 'undefined') {
			client = createPublicClient({
				transport: custom(window.ethereum)
			});

			walletClient = createWalletClient({
				transport: custom(window.ethereum)
			});

			account = await getAddress();
			chainId = await client.getChainId();
			nftMetadatas = await metadataGet();

			window.ethereum.on('accountsChanged', (_accounts: string[]) => {
				console.log('🚀 ~ file: +page.svelte:29 ~ window.ethereum.on ~ _accounts:', _accounts);
				account = _accounts[0];
			});

			window.ethereum.on('chainChanged', (_chainId: string) => {
				console.log('🚀 ~ file: +page.svelte:33 ~ window.ethereum.on ~ _chainId:', _chainId);
				chainId = parseInt(_chainId, 16);
				console.log(
					'🚀 ~ file: +page.svelte:34 ~ window.ethereum.on ~ _chainId.toString():',
					parseInt(_chainId, 16)
				);
			});
		}
	});

	// NFT
	const metadataGet = async () => {
		const response = await fetch(
			'https://bafkreiftw5gka5jz5bor3qmwym2df6bcdt6obh4j4piowousxfl3tfb4gi.ipfs.nftstorage.link/'
		);
		const jsonData = await response.json();
		console.log(jsonData);

		return jsonData;
	};

	// VIEM
	const getAddress = async () => {
		const addresses = await walletClient.getAddresses();
		console.log('addresses:', addresses);
		console.log('address current:', addresses[0]);
		return addresses[0];
	};

	const getAddresses = async () => {
		const addresses = await walletClient.getAddresses();
		console.log('addresses:', addresses);
		console.log('address current:', addresses[0]);
		return addresses;
	};

	const getBalance = async () => {
		const balance = await client.getBalance({
			address: await getAddress()
		});
		console.log('🚀 ~ file: +page.svelte:75 ~ getBalance ~ balance:', balance);
		return balance;
	};

	const getBlockNumber = async () => {
		const blockNumber = await client.getBlockNumber();
		console.log('🚀 ~ file: +page.svelte:81 ~ getBlockNumber ~ blockNumber:', blockNumber);
		return blockNumber;
	};

	const connectMetamask = async () => {
		if (typeof window.ethereum !== 'undefined') {
			[account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
		}
	};
</script>

<p>Connect your Metamask and choose your files</p>
<button on:click={connectMetamask}>connect</button>
<button on:click={getAddress}>get address</button>
<button on:click={getBalance}>get balance</button>
<button on:click={getBlockNumber}>get block number</button>

<section>
	{#if account}
		<h3>{account}</h3>
	{/if}
</section>
