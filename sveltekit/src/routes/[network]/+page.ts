import type { Load } from '@sveltejs/kit';

import jsonFile from '$addresses';

const load: Load = async ({ params }) => {
  const network = params.network;
	const chainId = network == 'sepolia' ? 11155111 : 100;
	const json = jsonFile[chainId];
	return {
    network,
		chainId,
		json
	};
};

export { load };
