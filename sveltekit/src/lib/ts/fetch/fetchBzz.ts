import {
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	ZERO_BYTES32
} from '../constants/constants';
import { utilsError } from '../common/utils';
import { localConfigGet } from '../common/local';
import { fetchAltUrl, fetchUrlOk } from './fetch';

import type { Hex } from 'viem';

const fetchBzzPost = async (url: URL | string | undefined): Promise<string | undefined> => {
	if (!(url && fetchUrlOk(url))) throw new Error(`fetchBzzPost: Bad URL ${url}`);

	const swarmApiUrl = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (batchId === ZERO_BYTES32) throw new Error('fetchBzzPost: No BatchId defined!');

	const urlAlt = await fetchAltUrl(url);
  if (!urlAlt) throw new Error(`fetchBzzPost: Bad URL ${url}`);

  const body = await (await fetch(urlAlt)).blob();

	const headers = new Headers();
	headers.append('Content-Type', body.type);
	headers.append('swarm-postage-batch-id', batchId);

	const response: Response = await fetch(swarmApiUrl, { method: 'POST', body, headers });

	const json = await response.json();
	if (!response.ok) {
		throw Error(`${response.statusText}\n${JSON.stringify(json, null, 2)}`);
	}

	return `${SWARM_GATEWAY}/${json.reference}`;
};

const fetchBzzGet = async (bzzHash: Hex): Promise<Response | undefined> => {
	console.info('fetchBzzGet', bzzHash);

	try {
		const url = `${SWARM_GATEWAY}/${bzzHash}`;
		const response = await fetch(url);
		console.log('fetchBzzGet', bzzHash, '\n', response);
		return response;
	} catch (e) {
		utilsError(`fetchBzzGet: Error ${bzzHash}`, e);
	}
};

export { fetchBzzGet, fetchBzzPost };
