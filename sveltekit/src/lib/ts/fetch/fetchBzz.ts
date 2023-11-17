import type { Hex } from 'viem';
import {   SWARM_API, SWARM_GATEWAY } from '../constants/constants';

const fetchBzzPost = async (url: string | undefined, batchId: Hex): Promise<string | undefined> => {
	console.info('fetchBzzPost');

	try {
		if (!url) throw new Error('url is undefined');

		const urlApi = `${SWARM_API}/bzz`;

		const body = await (await fetch(url)).blob();
		console.log('fetchBzzPost ~ body', body.size, body.type);

		const headers = new Headers();
		headers.append('Content-Type', body.type);
		headers.append('swarm-postage-batch-id', batchId);

		const response = await fetch(urlApi, { method: 'POST', body, headers });
		const json = await response.json();
		const urlResaved = `${SWARM_GATEWAY}/${json.reference}`;

		console.log('fetchBzzPost ~ urlResaved:', urlResaved);
		return urlResaved;
	} catch (e) {
		console.log('fetchBzzPost failed with error', e);
	}
};

const fetchBzzGet = async (swarmHash: string): Promise<Response | undefined> => {
	console.info('fetchBzzGet', swarmHash);

	try {
		const url = `${SWARM_GATEWAY}/${swarmHash}`;
		const response = await await fetch(url);
		console.log('fetchBzzGet', swarmHash, '\n', response);
		return response;
	} catch (e) {
		console.log('fetchBzzGet failed with error', e, swarmHash);
	}
};

export { fetchBzzGet, fetchBzzPost };
