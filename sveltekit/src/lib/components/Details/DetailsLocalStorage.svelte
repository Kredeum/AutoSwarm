<script lang="ts">
	import { localConfigGet } from '$lib/ts/common/local';
	import { onMount } from 'svelte';

	///////////////////////////// Details Local Storage /////////////////////////////////
	// <DetailsLocalStorage fields />
	/////////////////////////////////////////////////////////////////////////////////////
	export let fields: string | undefined = undefined;
	/////////////////////////////////////////////////////////////////////////////////////

	let localApi: string | null;
	let localBatchId: string | null;
	let localGateway: string | null;
	let localBzzChainId: string | null;

	const refresh = async () => {
		localApi = localConfigGet('api');
		localBatchId = localConfigGet('batchId');
		localGateway = localConfigGet('gateway');
		localBzzChainId = localConfigGet('bzzChainId');
	};

	const isField = (field: string): boolean => !fields || fields.includes('field');

	onMount(async () => {
		await refresh();
	});
</script>

{#if !fields || fields.includes('batchId')}
	<p>
		LocalStorage | BatchId
		<span>
			{localBatchId}
		</span>
	</p>
{/if}

{#if isField('api')}
	<p>
		LocalStorage | Bee node API URL
		<span>
			{localApi}
		</span>
	</p>
{/if}

{#if isField('gateway')}
	<p>
		LocalStorage | Swarm Gateway URL
		<span>
			{localGateway}
		</span>
	</p>
{/if}

{#if isField('bzzChainId')}
	<p>
		LocalStorage | BzzChainId
		<span>
			{localBzzChainId}
		</span>
	</p>
{/if}

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
