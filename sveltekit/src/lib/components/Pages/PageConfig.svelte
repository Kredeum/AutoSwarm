<script lang="ts">
	import { localConfigSet } from '$lib/ts/common/local';
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';

	import { beeApi, beeBatchId } from '$lib/ts/swarm/bee';

	////////////////////// Swarm Config Component ///////////////////////////////
	// <Config />
	/////////////////////////////////////////////////////////////////////////////
	// Config stored in localStorage
	// - swarm.api     : Swarm node API URL, default http://127.0.0.1:1633/bzz
	// - swarm.batchId : Swarm Batch Id, default 0x0
	/////////////////////////////////////////////////////////////////////////////

	let errMessage = '';
	let successMessage = '';

	let swarmApi = beeApi();
	let batchId = beeBatchId() as string;

	const isUrlValid = (url: string): boolean => {
		if (!url) return false;
		try {
			new URL(url);
			return true;
		} catch (e) {
			return false;
		}
	};

	const isBatchIdValid = (batchId: string | undefined): boolean =>
		Boolean(batchId?.replace(/^0x/, '').length === 64);

	const resetMessages = () => {
		errMessage = '';
		successMessage = '';
	};

	const storeUserSettings = (): void => {
		resetMessages();

		swarmApi = swarmApi.trim().replace(/\/$/, '');
		if (!isUrlValid(swarmApi)) {
			errMessage = `Invalid node URL '${swarmApi}'`;
			swarmApi = beeApi();
			return;
		}
		localConfigSet('api', swarmApi);

		batchId = batchId?.trim();
		console.log('storeUserSettings ~ batchId:', batchId);
		if (isBatchIdValid(batchId)) {
			successMessage = 'Swarm config stored';
			localConfigSet('batchId', `0x${batchId!.replace(/^0x/, '')}`);
		} else {
			errMessage = `Invalid batchId '${batchId}'`;
			batchId = beeBatchId();
			return;
		}

		setTimeout(() => resetMessages(), 2000);
	};
</script>

<div id="config">
	<h2>Config</h2>
	<div id="config-content">
		<label class="input-label" for="swarm-api">Bee node URL</label>
		<input
			type="text"
			class="input-field"
			placeholder="Enter your bee node URL"
			bind:value={swarmApi}
			id="swarm-api"
			on:input={resetMessages}
		/>

		<label class="input-label" for="batch-id">Batch Id</label>
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
	</div>
</div>

<style>
	#config {
		display: flex;
		align-items: center;
		flex-direction: column;
	}
	#config h2 {
		color: var(--color-link);
	}

	#config-content {
		width: 650px;
		max-width: 90vw;
		display: flex;
		align-items: center;
		flex-direction: column;
	}
</style>
