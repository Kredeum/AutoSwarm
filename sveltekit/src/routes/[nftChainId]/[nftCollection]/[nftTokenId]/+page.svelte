<script lang="ts">
	import type { Address } from 'viem';

	import AutoSwarm from '$lib/components/Nft/NftAutoSwarm.svelte';
	import { page } from '$app/stores';
	import { callNftMetadata } from '$lib/ts/call/callNftMetadata';

	////////////////////// AutoSwarm NFT Page ///////////////////////////////////
	// Get NFT identification from URL
	// http://host/{nftChainId}/{nftCollection}/{nftTokenId}
	// then get NFT metadata
	/////////////////////////////////////////////////////////////////////////////

	// NFT identification
	const nftChainId = Number($page.params.nftChainId);
	const nftCollection = $page.params.nftCollection as Address;
	const nftTokenId = BigInt($page.params.nftTokenId);

	// NFT metadata
	const asyncNftMetadata = async () => await callNftMetadata(nftChainId, nftCollection, nftTokenId);
</script>

{#await asyncNftMetadata()}
	<p>Loading NFT metadata...</p>
	<p>NFT #{nftChainId} / @{nftCollection} / #{nftTokenId}</p>
{:then nftMetadata}
	<AutoSwarm {nftMetadata} />
{:catch error}
	<p>Error:</p>
	<pre>{error.message}</pre>
{/await}
