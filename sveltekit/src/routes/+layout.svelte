<script>
	import Header from './Header.svelte';
	import './styles.css';
</script>

<div class="app">
	<Header />

	<main>
		<slot />
	</main>

	<footer>
		<p>visit <a href="https://app.kredeum.com">Kredeum Nfts Factory</a> to Mint your Nfts</p>
	</footer>
</div>
