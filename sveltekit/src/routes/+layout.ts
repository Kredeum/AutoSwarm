import type { Load } from '@sveltejs/kit';

import { bzzChain, bzzJson, bzzChainId } from '$lib/ts/swarm/bzz';
import { localConfigGet, localConfigInit } from '$lib/ts/common/local';

const prerender = false;
const ssr = false;

const load: Load = async () => {
	localConfigInit();
	bzzChainId.set(Number(localConfigGet('bzzChainId')));

	return {
		chain: bzzChain(),
		json: bzzJson()
	};
};

export { prerender, ssr, load };
