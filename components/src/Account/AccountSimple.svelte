<script lang="ts">
	import { callEnsName } from '@autoswarm/common/src/call/call';
	import type { Address } from 'viem';

	export let account: Address;
</script>

{#await callEnsName(account)}
	{account}
{:then accountEns}
	{accountEns || account}
{/await}
