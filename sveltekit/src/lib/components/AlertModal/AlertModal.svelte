<script lang="ts">
	import { fade, fly } from 'svelte/transition';
	import { quintOut, bounceOut } from 'svelte/easing';

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
		if (messageStatus !== 'error') timeoutId = setTimeout(() => resetMessage(), 5000);
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
		in:fly={{ delay: 0, duration: 300, x: 100, y: 0, opacity: 0.5, easing: easingMode() }}
		out:fade={{ duration: 500 }}
	>
		<button on:click={resetMessage} on:keydown={resetMessage} title="Close" class="modal-close"
			><i class="fa fa-times" />
		</button>
		<p>{messageStatus === 'error' ? 'Ooops !' : 'Great !'}</p>
		<pre>{message}</pre>
	</div>
{/if}

<style>
	.alert-message {
		background-color: #fff;
		border-radius: 6px;
		position: fixed;
		left: 5em;
		top: 3em;
		padding: 0em 2em;
	}

	.alert-error-message {
		color: red;
	}

	.alert-success-message {
		color: rgb(16, 163, 16);
	}

	.modal-close {
		position: absolute;
		top: 1em;
		right: 1em;
		border: none;
		background-color: transparent;
		cursor: pointer;
	}

	pre {
		white-space: pre-line;
	}
</style>
