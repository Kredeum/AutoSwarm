import type { Load } from '@sveltejs/kit';

import { type Chain, gnosis, sepolia } from 'viem/chains';
import { anvil } from '$lib/ts/anvil.js';

import jsonFile from '$addresses';
import type { ChainIdInJson } from '$lib/ts/get';

const load: Load = async ({ params }) => {
	let chain: Chain = gnosis;
	const networkParam = params.network;

	const json = jsonFile[chain.id as ChainIdInJson];

	if (Number(networkParam) == 11155111 || networkParam == 'sepolia') {
		chain = sepolia;
		json.batchId = '0x0';
	} else if (Number(networkParam) == 31337 || networkParam == 'anvil') {
    chain = anvil;
		json.batchId = '0x0';
	} else {
		chain = gnosis;
		json.batchId = '0x0';
	}

	return {
		chain,
		json
	};
};

export { load };
