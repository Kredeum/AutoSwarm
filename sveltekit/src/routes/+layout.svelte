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
		<p>
			visit <a href="https://app.kredeum.com" target="_blank" rel="noopener noreferrer"
				>Kredeum Nfts Factory</a
			> to Mint your NFTs :)
		</p>
	</footer>
</div>
