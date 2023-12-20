<script lang="ts">
	import type { Address } from 'viem';
	import type { Metadata, NftMetadata } from '$lib/ts/constants/types';
	import { displayNftLink } from '$lib/ts/display/display';

	////////////////////// NFT Component ///////////////////////////////////////
	// <Nft {metadata} />
	//////////////////////////////////////////////////////////////////////////////
	export let metadata: Metadata;
	export let nftMetadata: NftMetadata;
	////////////////////////////////////////////////////////////////////////////
</script>

<article>
	<div
		title="NFT Collection Address  @{nftMetadata.nftCollection || ''}"
		class="nft-img"
		style="background-image: url({nftMetadata.nftImageUriAlt || ''});"
		aria-label={metadata.description || ''}
	/>
	<p class="nft-title">
		{metadata.name || ''}
		&nbsp;
		<span>
			{@html displayNftLink(
				nftMetadata.nftChainId,
				nftMetadata.nftCollection,
				nftMetadata.nftTokenId
			)}
		</span>
	</p>
</article>

<style>
	p span {
		float: right;
	}
</style>
