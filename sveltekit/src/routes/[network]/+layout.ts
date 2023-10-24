import type { Load } from '@sveltejs/kit';

import { type Chain, gnosis, sepolia } from 'viem/chains';
import { anvil } from '$lib/ts/anvil.js';

import jsonFile from '$addresses';
import type { ChainIdInJson } from '$lib/ts/get';

const load: Load = async ({ params }) => {
	let chain: Chain = gnosis;
	const networkParam = params.network;

	if (Number(networkParam) == 11155111 || networkParam == 'sepolia') {
		chain = sepolia;
	}
	if (Number(networkParam) == 31337 || networkParam == 'anvil') chain = anvil;

	const json = jsonFile[chain.id as ChainIdInJson];

	return {
		chain,
		json
	};
};

export { load };
