<script lang="ts">
	import { readEnsName } from '$lib/ts/onchain/read';
	import type { Address } from 'viem';

	export let account: Address;
</script>

{#await readEnsName(account)}
	{account}
{:then accountEns}
	{accountEns || account}
{/await}
