<script lang="ts">
	import { callEnsName } from '$lib/ts/call/call';
	import type { Address } from 'viem';

	export let account: Address;
</script>

{#await callEnsName(account)}
	{account}
{:then accountEns}
	{accountEns || account}
{/await}
