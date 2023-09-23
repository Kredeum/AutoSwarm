import type { Load } from '@sveltejs/kit';

import jsonFile from '$addresses';

const load: Load = async ({ params }) => {
	const network = params.network;
	const chainId =
		network == 'sepolia' ? 11155111 : network == 'gnosis' ? 100 : network == 'anvil' ? 31337 : 1337;
	const json = jsonFile[chainId];
	return {
		network,
		chainId,
		json
	};
};

export { load };
