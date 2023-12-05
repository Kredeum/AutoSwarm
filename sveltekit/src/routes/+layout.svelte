<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import AlertModal from '$lib/components/AlertModal/AlertModal.svelte';
	import Header from '$lib/components/Layout/LayoutHeader.svelte';
	import Footer from '$lib/components/Layout/LayoutFooter.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { page } from '$app/stores';

	////////////////////// AutoSwarm Layout ///////////////////////////////////////
	// Layout for all AutoSwamr pages
	/////////////////////////////////////////////////////////////////////////////

	// let chainId: number = 100;
	let chainId: number = 11155111;
	// let chainId: number = 31337;
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
	<AlertModal />

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
