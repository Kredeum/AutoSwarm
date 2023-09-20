<script>
	import Header from '$lib/svelte/Header.svelte';
	import Footer from '$lib/svelte/Footer.svelte';
	import '$lib/css/styles.css';
</script>

<div class="app">
	<Header />

	<main>
		<slot />
	</main>

	<Footer />


</div>
