<script lang="ts">
	import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID } from '$lib/ts/constants/constants';
	import { localConfigGet, localConfigSet } from '$lib/ts/constants/local';
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';
	import { trim } from 'viem';

	let errMessage = '';
	let successMessage = '';

	$: swarmApi = localConfigGet('api') || SWARM_DEFAULT_API;
	$: batchId = localConfigGet('batchId');

	const isUrlValid = (url: string): boolean => {
		if (!url) return false;
		try {
			new URL(url);
			return true;
		} catch (e) {
			return false;
		}
	};

	const isBatchIdValid = (batchId: string | null): boolean =>
		!batchId || batchId.replace(/^0x/, '').length === 64;

	const resetMessages = () => {
		errMessage = '';
		successMessage = '';
	};

	const storeUserSettings = (): void => {
		resetMessages();

		swarmApi = swarmApi.trim().replace(/\/$/, '');
		if (!isUrlValid(swarmApi)) {
			errMessage = `Invalid node URL '${swarmApi}'`;
			swarmApi = localConfigGet('api') || SWARM_DEFAULT_API;
			return;
		}
		localConfigSet('api', swarmApi);

		batchId = batchId?.trim() || null;
		batchId = batchId?.replace(/^0x/, '') || null;
		if (batchId !== null) batchId = `0x${batchId}`;
		if (!(batchId && isBatchIdValid(batchId))) {
      errMessage = `Invalid batchId '${batchId}'`;
			batchId = localConfigGet('batchId') || null;
			return;
		}
		localConfigSet('batchId', batchId);

		successMessage = 'Swarm config stored';
		setTimeout(() => resetMessages(), 2000);
	};
</script>

<section id="swarm-config">
	<h2>Config</h2>

	<label class="input-label" for="swarm-api">Bee node URL</label>
	<input
		type="text"
		class="input-field"
		placeholder="Enter your bee node URL"
		bind:value={swarmApi}
		id="swarm-api"
		on:input={resetMessages}
	/>

	<label class="input-label" for="batch-id">BatchID</label>
	<input
		type="text"
		class="input-field"
		placeholder="Enter your batch ID"
		bind:value={batchId}
		id="batch-id"
		on:input={resetMessages}
	/>

	<input
		type="submit"
		on:click|preventDefault={storeUserSettings}
		class="btn btn-submit"
		value="Store Swarm config"
	/>
	{#if errMessage}
		<p
			class="error-message"
			in:fly={{ delay: 0, duration: 300, x: 0, y: 100, opacity: 0.5, easing: bounceOut }}
			out:fade={{ duration: 300 }}
		>
			Ooops, {errMessage}
		</p>
	{:else if successMessage}
		<p
			class="success-message"
			in:fly={{ delay: 0, duration: 300, x: 0, y: 100, opacity: 0.5, easing: quintOut }}
			out:fade={{ duration: 300 }}
		>
			{successMessage}
		</p>
	{/if}
</section>
