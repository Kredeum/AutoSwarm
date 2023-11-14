import type { Load } from '@sveltejs/kit';

import { bzzChain, bzzJson } from '$lib/ts/swarm/bzz';

const prerender = false;
const ssr = false;

const load: Load = async () => {
	return {
		chain: bzzChain(),
		json: bzzJson()
	};
};

export { prerender, ssr, load };
