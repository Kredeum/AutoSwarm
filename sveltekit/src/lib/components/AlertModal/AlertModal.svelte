<script lang="ts">
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';
	import { clickOutside } from '$lib/ts/common/clickOutside';

	import { alertMessage } from '$lib/ts/stores/alertMessage';

	////////////////////// Swarm alert modal Component /////////////////////
	// <AlertModal />
	////////////////////////////////////////////////////////////////////////

	let alertTimeoutId: ReturnType<typeof setTimeout>;
	const alertEasingMode = () => ($alertMessage.status === 'error' ? bounceOut : quintOut);

	$: $alertMessage && alertDisplay();
	const alertDisplay = () => {
		clearTimeout(alertTimeoutId);
		if ($alertMessage.status !== 'error') alertTimeoutId = setTimeout(() => alertReset(), 8000);
	};

	const alertReset = () => {
		$alertMessage = {};
		clearTimeout(alertTimeoutId);
	};
</script>

{#if $alertMessage?.status}
	<div
		class="alert-message alert-{$alertMessage.status}-message"
		role="alert"
		in:fly={{ delay: 0, duration: 300, x: 100, y: 0, opacity: 0.5, easing: alertEasingMode() }}
		out:fade={{ duration: 500 }}
		use:clickOutside={alertReset}
	>
		<button
			on:click={alertReset}
			on:keydown={alertReset}
			class="modal-close"
			title="Close"
			aria-label="Close"
		>
			<i class="fa fa-times" />
		</button>

		<p>
			{#if $alertMessage.status === 'error'}
				<i class="fa-solid fa-circle-exclamation" />
			{:else if $alertMessage.status === 'success'}
				<i class="fa-solid fa-circle-check" />
			{:else}
				<i class="fa-solid fa-circle-info" />
			{/if}
			<span>{$alertMessage?.title || ''}</span>
		</p>
		<pre>{$alertMessage?.detail || ''}</pre>
	</div>
{/if}

<style>
	.alert-message {
		/* background-color: #fff; */
		background-color: #000;
		border-radius: 1.5em;
		position: fixed;
		left: 50%;
		transform: translateX(-50%);
		top: 3em;
		padding: 0em 2.5em;
		max-width: 90%;
		color: #fff;
		border: 2px solid var(--color-link);
	}

	span {
		margin: 1em;
	}

	.modal-close {
		position: absolute;
		top: 0.8em;
		right: 0.8em;
		border: none;
		background-color: transparent;
		cursor: pointer;
	}

	.modal-close i {
		font-size: 1.5em;
		color: #fff;
	}

	.fa-circle-exclamation {
		color: red;
	}

	.fa-circle-check {
		color: rgb(16, 163, 16);
	}

	pre {
		white-space: pre-line;
		word-wrap: break-word;
		font-family: var(--font-body);
	}

	/* .alert-error-message {
    color: red;
  }

  .alert-success-message {
    color: rgb(16, 163, 16);
  } */
</style>
