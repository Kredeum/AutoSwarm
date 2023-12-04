<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import Header from '$lib/components/Layout/LayoutHeader.svelte';
	import Footer from '$lib/components/Layout/LayoutFooter.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { page } from '$app/stores';

	////////////////////// AutoSwarm Layout ///////////////////////////////////////
	// Layout for all AutoSwamr pages
	/////////////////////////////////////////////////////////////////////////////

	const chainId = localStorage.getItem('swarm.chainId') || '11155111'; //  "31337" // "100";
	localStorage.setItem('swarm.chainId', chainId);
	bzzChainId.set(Number(chainId));

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
