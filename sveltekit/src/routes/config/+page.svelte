<script lang="ts">
	import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID } from '$lib/ts/constants/constants';
	import { localConfigGet, localConfigSet } from '$lib/ts/constants/local';

	let errMessage = '';
	let successMessage = '';

	$: swarmApi = localConfigGet('api') || SWARM_DEFAULT_API;
	$: batchId = localConfigGet('batchId') || SWARM_DEFAULT_BATCHID;

	const isUrlValid = (url: string): boolean => {
		try {
			new URL(url);
			return true;
		} catch (e) {
			return false;
		}
	};

	const isBatchIdValid = (batchId: string): boolean => {
		return batchId.replace(/^0x/, '').length === 64;
	};

	const storeUserSettings = (): void => {
		errMessage = '';

		if (!isUrlValid(swarmApi)) {
			errMessage += 'Invalid url';
		}

		if (!isBatchIdValid(batchId)) {
			if (errMessage) errMessage += ' & ';
			errMessage += 'Invalid batchId';
		}

		if (errMessage) return;

		localConfigSet('api', swarmApi);
		localConfigSet('batchId', batchId);
		successMessage = 'Swarm config stored';
	};
</script>

<h2>Config</h2>

<section id="swarm-config">
	<label class="input-label" for="swarm-api">Bee node URL</label>
	<input
		type="text"
		class="input-field"
		placeholder="Enter your bee node URL"
		bind:value={swarmApi}
		id="swarm-api"
	/>

	<label class="input-label" for="batch-id">BatchID</label>
	<input
		type="text"
		class="input-field batchid-field"
		placeholder="Enter your bee node URL"
		bind:value={batchId}
		id="batch-id"
	/>

	<input
		type="submit"
		on:click|preventDefault={storeUserSettings}
		class="btn btn-submit"
		value="Store Swarm config"
	/>
	{#if errMessage}
		<p class="error-message">{errMessage}</p>
	{:else if successMessage}
		<p class="success-message">{successMessage}</p>
	{/if}
</section>
