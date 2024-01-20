<script lang="ts">
	import type { Address } from 'viem';
	import { page } from '$app/stores';
	import { callNftMetadata } from '@autoswarm/common/src/call/callNftMetadata';
	import NftAutoSwarm from '@autoswarm/components/src/Nft/NftAutoSwarm.svelte';

	////////////////////// AutoSwarm NFT Page ///////////////////////////////////
	// Get NFT identification from URL
	// http://host/{nftChainId}/{nftCollection}/{nftTokenId}
	// then get NFT nftMetadata
	/////////////////////////////////////////////////////////////////////////////

	// NFT identification
	const nftChainId = Number($page.params.nftChainId);
	const nftCollection = $page.params.nftCollection as Address;
	const nftTokenId = BigInt($page.params.nftTokenId);
</script>

{#await callNftMetadata(nftChainId, nftCollection, nftTokenId)}
	<p>Loading NFT metadata...</p>
	<p>NFT #{nftChainId} / @{nftCollection} / #{nftTokenId}</p>
{:then [metadata, nftMetadata]}
	<NftAutoSwarm {metadata} {nftMetadata} />
{:catch error}
	<p>Error:</p>
	<pre>{error.message}</pre>
{/await}
