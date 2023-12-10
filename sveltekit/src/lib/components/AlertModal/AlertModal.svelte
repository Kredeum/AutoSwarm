<script lang="ts">
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';
	import { clickOutside } from '$lib/ts/common/clickOutside';

	import { alertMessage } from '$lib/ts/stores/alerts';

	////////////////////// Swarm alert modal Component /////////////////////
	// <AlertModal />
	////////////////////////////////////////////////////////////////////////

	let modalOpen = false;
	let timeoutId: NodeJS.Timeout;

	$: messageStatus = $alertMessage.status;
	$: message = $alertMessage.message;

	$: messageStatus && displayMessage();
	const displayMessage = () => {
		clearTimeout(timeoutId);
		modalOpen = true;
		if (messageStatus === 'success') timeoutId = setTimeout(() => resetMessage(), 5000);
	};

	const easingMode = () => (messageStatus === 'error' ? bounceOut : quintOut);

	const resetMessage = () => {
		modalOpen = false;
		$alertMessage = { status: '', message: '' };
		clearTimeout(timeoutId);
	};
</script>

{#if modalOpen}
	<div
		class="alert-message alert-{messageStatus}-message"
		role="alert"
		in:fly={{ delay: 0, duration: 300, x: 100, y: 0, opacity: 0.5, easing: easingMode() }}
		out:fade={{ duration: 500 }}
		use:clickOutside={resetMessage}
	>
		<button
			on:click={resetMessage}
			on:keydown={resetMessage}
			class="modal-close"
			title="Close"
			aria-label="Close"
		>
			<i class="fa fa-times" />
		</button>

		<p>
			{#if messageStatus === 'error'}
				<i class="fa-solid fa-circle-exclamation" /> Ooops !
			{:else if messageStatus === 'success'}
				<!-- <i class="fa-regular fa-circle-check" /> -->
				<i class="fa-solid fa-circle-check" /> Great !
			{:else}
				<i class="fa-solid fa-circle-info" />
			{/if}
		</p>
		<pre>{message}</pre>
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

	/* .alert-error-message {
		color: red;
	}

	.alert-success-message {
		color: rgb(16, 163, 16);
	} */

	.modal-close {
		position: absolute;
		top: 0.3em;
		right: 0.3em;
		border: none;
		background-color: transparent;
		cursor: pointer;
	}

	.modal-close i {
		font-size: 2em;
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
</style>
