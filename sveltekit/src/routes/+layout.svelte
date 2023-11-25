<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import Header from '$lib/components/Layout/Header.svelte';
	import Footer from '$lib/components/Layout/Footer.svelte';
	import NetworkListSelectSimple from '$lib/components/Network/NetworkListSelectSimple.svelte';
	import AccountConnectSimple from '$lib/components/Account/AccountConnectSimple.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { page } from '$app/stores';
	import type { as } from 'vitest/dist/reporters-5f784f42';
	import { onMount } from 'svelte';

	// let chainId: number = 100;
	// let chainId: number = 11155111;
	let chainId: number = 31337;
	$: chainId, onChainChange();

	const onChainChange = () => {
		bzzChainId.set(chainId);
		invalidateAll();
	};

	$: document.body.style.backgroundColor = ['/monitor', '/config'].includes($page.route.id || '')
		? '#444'
		: '#000';
</script>

<div class="app">
	<header>
		<Header />
	</header>

	<main>
		<slot />
	</main>

	<footer>
		{chainId}
		<Footer />
	</footer>
</div>
