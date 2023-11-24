import {
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	ZERO_BYTES32
} from '../constants/constants';
import { utilsError } from '../swarm/utils';
import { localConfigGet } from '../constants/local';
import { fetchUrlOk } from './fetch';

import type { Hex } from 'viem';

const fetchBzzPost = async (url: URL | string | undefined): Promise<URL | undefined> => {
	if (!(url && fetchUrlOk(url))) throw new Error('Bad URL');

	const swarmApiUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (batchId === ZERO_BYTES32) throw new Error('No BatchId defined!');

	const body = await (await fetch(url)).blob();

	const headers = new Headers();
	headers.append('Content-Type', body.type);
	headers.append('swarm-postage-batch-id', batchId);

	const response: Response = await fetch(swarmApiUrl, { method: 'POST', body, headers });

	const json = await response.json();
	if (!response.ok) {
		throw Error(`${response.statusText}\n${JSON.stringify(json, null, 2)}`);
	}

	return new URL(`${SWARM_GATEWAY}/${json.reference}`);
};

const fetchBzzGet = async (bzzHash: Hex): Promise<Response | undefined> => {
	console.info('fetchBzzGet', bzzHash);

	try {
		const url = `${SWARM_GATEWAY}/${bzzHash}`;
		const response = await await fetch(url);
		console.log('fetchBzzGet', bzzHash, '\n', response);
		return response;
	} catch (e) {
		utilsError(`fetchBzzGet: Error ${bzzHash}`, e);
	}
};

export { fetchBzzGet, fetchBzzPost };
