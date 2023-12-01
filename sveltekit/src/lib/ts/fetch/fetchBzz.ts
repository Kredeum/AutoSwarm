import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID, SWARM_GATEWAY } from '../constants/constants';
import { utilsError, utilsIsBytes32Null } from '../common/utils';
import { localConfigGet } from '../common/local';
import { fetchSuccess, fetchUrl, fetchUrlOk } from './fetch';
import { fetchAltUrl } from './fetchAlt';

import type { Hex } from 'viem';

const fetchBzzPost = async (url: URL | string | undefined): Promise<string | undefined> => {
	if (!(url && fetchUrlOk(url))) throw new Error(`fetchBzzPost: Bad URL ${url}`);

	const swarmApiUrl = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (utilsIsBytes32Null(batchId)) throw new Error('fetchBzzPost: No BatchId defined!');

	const urlAlt = await fetchAltUrl(url);
	if (!urlAlt) throw new Error(`fetchBzzPost: Bad URL ${url}`);

	const resp = await fetchUrl(urlAlt);
	if (!resp) throw new Error(`fetchBzzPost: Bad URL ${urlAlt}`);
	const body = await resp.blob();

	const headers = new Headers();
	headers.append('Content-Type', body.type);
	headers.append('swarm-postage-batch-id', batchId);

	const response = await fetch(swarmApiUrl, { method: 'POST', headers, body });
	if (!fetchSuccess(response.status)) throw Error(`fetchBzzPost: ${response.status}`);
	const json = await response.json();

	return `${SWARM_GATEWAY}/${json.reference}`;
};

const fetchBzzGet = async (bzzHash: Hex): Promise<Response | undefined> => {
	console.info('fetchBzzGet', bzzHash);

	const url = `${SWARM_GATEWAY}/${bzzHash}`;
	const response = await fetchUrl(url);
	console.log('fetchBzzGet', bzzHash, '\n', response);
	return response;
};

export { fetchBzzGet, fetchBzzPost };
