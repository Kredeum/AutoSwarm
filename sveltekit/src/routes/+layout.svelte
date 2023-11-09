<script lang="ts">
	import Header from '$lib/svelte/Header.svelte';
	import Footer from '$lib/svelte/Footer.svelte';
	import { invalidateAll } from '$app/navigation';

	import NetworkListSelectSimple from '$lib/components/Network/NetworkListSelectSimple.svelte';
	import AccountConnectSimple from '$lib/components/Account/AccountConnectSimple.svelte';
	import '$lib/css/styles.css';

	import { bzzChainId } from '$lib/ts/bzz';

	let chainId: number = 11155111; // 100
	$: chainId, onChainChange();

	const onChainChange = () => {
		bzzChainId.set(chainId);
		invalidateAll();
	};
</script>

<div class="app">
	<header>
		<Header />
	</header>

	<main>
		<slot />
	</main>

	<footer>
		<AccountConnectSimple />
		<p>
			<NetworkListSelectSimple bind:chainId />
		</p>
		<Footer />
	</footer>
</div>
