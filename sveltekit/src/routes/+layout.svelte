<script lang="ts">
	import { invalidateAll } from '$app/navigation';

	import Header from '$lib/components/Layout/Header.svelte';
	import Footer from '$lib/components/Layout/Footer.svelte';
	import NetworkListSelectSimple from '$lib/components/Network/NetworkListSelectSimple.svelte';
	import AccountConnectSimple from '$lib/components/Account/AccountConnectSimple.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/swarm/bzz';
	import { page } from '$app/stores';

	let chainId: number = 11155111; // 100
	$: chainId, onChainChange();

	const onChainChange = () => {
		bzzChainId.set(chainId);
		invalidateAll();
	};

	const rootStyle = document.querySelector(':root')?.style;
	$: rootStyle.setProperty('--color-bg-0', $page.route.id === '/monitor' ? '#555' : '#000');
</script>

<div class="app">
	<header>
		<Header />
	</header>

	<main>
		<slot />
	</main>

	<footer>
		<p>
			<NetworkListSelectSimple bind:chainId />
		</p>
		<Footer />
	</footer>
</div>
