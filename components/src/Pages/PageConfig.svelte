<script lang="ts">
	import { localConfigSet } from '@autoswarm/common/src/common/local';
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';

	import { beeApi, beeBatchId, beeGatewayBzz } from '@autoswarm/common/src/swarm/bee';
	import { bzzChainsId, type BzzChainIdType } from '@autoswarm/common/src/common/chains';
	import { bzzChainId } from '@autoswarm/common/src/swarm/bzz';

	////////////////////// Swarm Config Component ///////////////////////////////
	// <Config />
	/////////////////////////////////////////////////////////////////////////////
	// Config stored in localStorage
	// - autoswarm.api     : Swarm Node API URL, default http://127.0.0.1:1633/bzz
	// - autoswarm.gateway : Swarm Gateway URL, default autoswarm.api
	// - autoswarm.batchId : Swarm Batch Id, default 0x0
	// - autoswarm.chainId : Swarm Chain Id, default 100
	/////////////////////////////////////////////////////////////////////////////

	let errMessage = '';
	let successMessage = '';

	let swarmApi = beeApi();
	let swarmGateway = beeGatewayBzz();
	let batchId = beeBatchId() as string;
	let chainId = $bzzChainId.toString();

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

	const isChainIdValid = (chainId: string | undefined): boolean =>
		bzzChainsId.includes(Number(chainId) as BzzChainIdType);

	const resetMessages = () => {
		errMessage = '';
		successMessage = '';
	};

	const storeUserSettings = (): void => {
		resetMessages();

		{
			swarmApi = swarmApi.trim().replace(/\/$/, '');
			if (!isUrlValid(swarmApi)) {
				errMessage = `Invalid node URL '${swarmApi}'`;
				swarmApi = beeApi();
				return;
			}
			localConfigSet('api', swarmApi);
		}
		{
			swarmGateway = swarmGateway.trim().replace(/\/$/, '');
			if (!isUrlValid(swarmGateway)) {
				errMessage = `Invalid node URL '${swarmGateway}'`;
				swarmGateway = beeGatewayBzz();
				return;
			}
			localConfigSet('gateway', swarmGateway);
		}

		{
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
		}

		{
			chainId = chainId?.trim();
			console.log('storeUserSettings ~ chainId:', chainId);
			if (isChainIdValid(chainId)) {
				successMessage = 'Swarm config stored';
				bzzChainId.set(Number(chainId));
				localConfigSet('bzzChainId', chainId);
			} else {
				errMessage = `Invalid chainId '${chainId}'`;
				chainId = $bzzChainId.toString();
				return;
			}
		}

		setTimeout(() => resetMessages(), 2000);
	};
</script>

<div id="config">
	<h2>Config</h2>
	<div id="config-content">
		<label class="input-label" for="batch-id">Batch Id</label>
		<input
			type="text"
			class="input-field"
			placeholder="Enter your batch ID"
			bind:value={batchId}
			id="batch-id"
			on:input={resetMessages}
		/>

		<label class="input-label" for="swarm-gateway">Bee node API URL</label>
		<input
			type="text"
			class="input-field"
			placeholder="Enter your Bee node API URL"
			bind:value={swarmApi}
			id="swarm-api"
			on:input={resetMessages}
		/>

		<label class="input-label" for="swarm-gateway">Swarm Gateway URL</label>
		<input
			type="text"
			class="input-field"
			placeholder="Enter your Swarm Gateway URL"
			bind:value={swarmGateway}
			id="swarm-gateway"
			on:input={resetMessages}
		/>

		<label class="input-label" for="chain-id">BZZ Chain Id</label>
		<input
			type="text"
			class="input-field"
			placeholder="Enter Chain ID"
			bind:value={chainId}
			id="chain-id"
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
