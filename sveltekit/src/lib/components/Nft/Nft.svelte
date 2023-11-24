<script lang="ts">
	import { callNftMetadata } from '$lib/ts/call/callNft';
	import type { NftMetadata } from '$lib/ts/constants/types';
	import { displayExplorerNft, displayNftLink } from '$lib/ts/display/display';
	import { utilsError } from '$lib/ts/swarm/utils';
	import { onMount } from 'svelte';
	import type { Address } from 'viem';
	import { bzzChainId } from '$lib/ts/swarm/bzz';

	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	export let nftMetadata: NftMetadata;

	$: autoSwarmMetadata = nftMetadata?.autoswarm;

	const refresh = async () => {
		console.log('<Nft refresh', $bzzChainId, nftChainId);
		try {
			nftMetadata = await callNftMetadata($bzzChainId, nftChainId, nftCollection, nftTokenId);
		} catch (e) {
			utilsError('<Nft refresh', e);
		}
	};

	onMount(refresh);
</script>

<article>
	<div
		title="NFT Collection Address  @{nftCollection}"
		class="nft-img"
		style="background-image: url({autoSwarmMetadata?.nftImageAlt ||autoSwarmMetadata?.tbaImageAlt || ''});"
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
