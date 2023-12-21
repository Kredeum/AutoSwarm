<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import AlertModal from '$lib/components/AlertModal/AlertModal.svelte';
	import Header from '$lib/components/Layout/LayoutHeader.svelte';
	import Footer from '$lib/components/Layout/LayoutFooter.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { page } from '$app/stores';
	import { localConfigGet, localConfigInit } from '$lib/ts/common/local';

	////////////////////// AutoSwarm Layout ///////////////////////////////////////
	// Layout for all AutoSwarm pages
	/////////////////////////////////////////////////////////////////////////////

	bzzChainId.set(Number(localConfigGet('chainId')));

	$: document.body.style.backgroundColor = ['/monitor'].includes($page.route.id || '')
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
