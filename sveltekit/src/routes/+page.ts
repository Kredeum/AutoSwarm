import type { Load } from '@sveltejs/kit';

const hash = 'ac94e9eb260b3754b9bf1a8397d78fb1e094c7314c1f265e2246ab1680032314';
const nftMetadataUrl: string = `https://api.gateway.ethswarm.org/bzz/${hash}/`;

const load: Load = async ({ fetch }) =>
	Object({
		nftMetadata: await (await fetch(nftMetadataUrl)).json()
	});

export { load };
