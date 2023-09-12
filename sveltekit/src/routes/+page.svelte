<script lang="ts">
	import type { WalletClient, PublicClient } from 'viem';
	import type { NftMetadata } from '$lib/types/types';

	import 'viem/window';
	import { createPublicClient, createWalletClient, custom } from 'viem';

	import { onMount } from 'svelte';

	import { abi, address } from '$lib/abis/hiConfig.json';

	let client: PublicClient;
	let walletClient: WalletClient;

	let account: string;
	let chainId: number;
	let collection: string;
	let tokenID: string = '81';

	let nftMetadatasUrl: string =
		'https://bafkreig3ovdhpxvxffv76zwkfwua5zb3fxtjsh2gphlqebgbbbny2o55dy.ipfs.nftstorage.link/';
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
		const response = await fetch(nftMetadatasUrl);
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

	const readContract = async () => {
		const result = await client.readContract({
			...{ abi, address: address as `0x${string}` },
			functionName: 'hi'
		});
		console.log('readContract ~ result:', result);
	};

	const connectMetamask = async () => {
		if (typeof window.ethereum !== 'undefined') {
			[account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
		}
	};
</script>

<div class="user-config">
	{#if !account}
		<button class="btn-connect" on:click={connectMetamask}>
			Connect your Metamask and choose your files
		</button>
	{/if}

	<div class="provisory">
		<button><a href="./auto">AutoSwarmAccount</a></button>
		<button on:click={getAddress}>get address</button>
		<button on:click={getBalance}>get balance</button>
		<button on:click={getBlockNumber}>get block number</button>
		<button on:click={readContract}>Read Hi contract</button>
	</div>

	{#if account}
		<p class="field-account">{account}</p>
		<p class="field-account">Chain ID : {chainId}</p>
	{/if}
</div>

<section>
	{#if account && nftMetadatas}
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas.image});"
				aria-label={nftMetadatas.description}
			/>
			<p>{nftMetadatas.name} <span># {tokenID}</span></p>
		</article>
		<!-- <article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article>
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article>
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article>
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article>
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article>
		<article>
			<div
				class="nft-img"
				style="background-image: url({nftMetadatas?.image});"
				aria-label={nftMetadatas?.description}
			/>
			<p>{nftMetadatas?.name} <span># {tokenID}</span></p>
		</article> -->
	{/if}
</section>
