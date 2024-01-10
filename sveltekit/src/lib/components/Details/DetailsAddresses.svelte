<script lang="ts">
	import { addressesGetField } from '$lib/ts/common/addresses';
	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import DetailsAddress from './DetailsAddress.svelte';

	///////////////////////////// Details Addresses /////////////////////////////////////
	// <DetailsAddresses />
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<DetailsAddress label="BzzToken" address={addressesGetField($bzzChainId, 'BzzToken')} />
<DetailsAddress
	label="AutoSwarmAccount"
	address={addressesGetField($bzzChainId, 'AutoSwarmAccount')}
/>
<DetailsAddress
	label="AutoSwarmMarket"
	address={addressesGetField($bzzChainId, 'AutoSwarmMarket')}
/>
<DetailsAddress
	label="ERC6551Registry"
	address={addressesGetField($bzzChainId, 'ERC6551Registry')}
/>
<DetailsAddress label="PostageStamp" address={addressesGetField($bzzChainId, 'PostageStamp')} />
<DetailsAddress label="PriceOracle" address={addressesGetField($bzzChainId, 'PriceOracle')} />
