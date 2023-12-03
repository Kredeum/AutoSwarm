<script lang="ts">
	import type { Address } from 'viem';
	import type { NftMetadata, NftMetadataAutoSwarm } from '$lib/ts/constants/types';
	import { displayNftLink } from '$lib/ts/display/display';

	////////////////////// NFT Component ///////////////////////////////////////
	// <Nft {metadata} />
	//////////////////////////////////////////////////////////////////////////////
	export let metadata: NftMetadata;
	////////////////////////////////////////////////////////////////////////////

	$: data = metadata?.autoSwarm;
</script>

<article>
	<div
		title="NFT Collection Address  @{data?.nftCollection || ''}"
		class="nft-img"
		style="background-image: url({data?.nftImageAlt || ''});"
		aria-label={metadata?.description || ''}
	/>
	<p class="nft-title">
		{metadata?.name || ''}
		&nbsp;
		<span>
			{@html displayNftLink(data?.nftChainId, data?.nftCollection, data?.nftTokenId)}
		</span>
	</p>
</article>

<style>
	p span {
		float: right;
	}
</style>
