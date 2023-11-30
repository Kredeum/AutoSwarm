<script lang="ts">
	import type { Address } from 'viem';
	import type { NftMetadata } from '$lib/ts/constants/types';
	import { displayNftLink } from '$lib/ts/display/display';

	////////////////////// NFT Component ///////////////////////////////////////
	// <Nft {nftChainId} {nftCollection} {nftTokenId} {nftMetadata} />
	////////////////////////////////////////////////////////////////////////////
	// - nftChainId    : NFT Chain Id
	// - nftCollection : NFT Collection Address
	// - nftTokenId    : NFT Token Id
	////////////////////////////////////////////////////////////////////////////
	export let nftChainId: number;
	export let nftCollection: Address;
	export let nftTokenId: bigint;
	export let nftMetadata: NftMetadata;
	////////////////////////////////////////////////////////////////////////////
</script>

<article>
	<div
		title="NFT Collection Address  @{nftCollection}"
		class="nft-img"
		style="background-image: url({nftMetadata?.autoSwarm?.nftImageAlt || ''});"
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
