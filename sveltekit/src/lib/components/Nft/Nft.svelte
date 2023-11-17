<script lang="ts">
	import { callNftMetadata } from '$lib/ts/call/callNft';
	import type { NftMetadata } from '$lib/ts/constants/constants';
	import { displayExplorerNft, displayNftLink } from '$lib/ts/display/display';
	import { onMount } from 'svelte';
	import type { Address } from 'viem';

	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	export let nftMetadata: NftMetadata;

	const refresh = async () => {
		try {
			nftMetadata = await callNftMetadata(nftChainId, nftCollection, nftTokenId);
		} catch (e) {
			alert(e);
		}
	};

	onMount(refresh);
</script>

<article>
	<div
		title="NFT Collection Address  @{nftCollection}"
		class="nft-img"
		style="background-image: url({nftMetadata?.imageAlt || ''});"
		aria-label={nftMetadata?.description || ''}
	/>
	<p class="nft-title">
		{nftMetadata?.name || ''}
		&nbsp;
		<span>
			{@html displayNftLink(nftChainId, nftCollection, nftTokenId)}
		</span>
	</p>
</article>

<style>
	p span {
		float: right;
	}
</style>
