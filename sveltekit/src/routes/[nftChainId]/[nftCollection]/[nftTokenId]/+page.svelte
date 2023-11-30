<script lang="ts">
	import type { Address } from 'viem';

	import AutoSwarm from '$lib/components/Nft/NftAutoSwarm.svelte';
	import { page } from '$app/stores';

	////////////////////// AutoSwarm NFT Page ///////////////////////////////////
	// Get NFT identification from URL
	// http://host/{nftChainId}/{nftCollection}/{nftTokenId}
	/////////////////////////////////////////////////////////////////////////////

	// NFT
	const nftChainId = Number($page.params.nftChainId);
	const nftCollection = $page.params.nftCollection as Address;
	const nftTokenId = BigInt($page.params.nftTokenId);
</script>

<AutoSwarm {nftChainId} {nftCollection} {nftTokenId} />
