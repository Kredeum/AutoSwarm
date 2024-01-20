<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import AlertModal from '@autoswarm/components/src/AlertModal/AlertModal.svelte';
	import Header from '@autoswarm/components/src/Layout/LayoutHeader.svelte';
	import Footer from '@autoswarm/components/src/Layout/LayoutFooter.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '@autoswarm/common/src/swarm/bzz';
	import { page } from '$app/stores';

	////////////////////// AutoSwarm Layout ///////////////////////////////////////
	// Layout for all AutoSwarm pages
	/////////////////////////////////////////////////////////////////////////////

	$: document.body.style.backgroundColor = ($page.route.id || '').includes('/monitor')
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
		{$bzzChainId}
		<Footer />
	</footer>
</div>
